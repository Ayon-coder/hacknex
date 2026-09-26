"""Port of renderThemeWav from lib/services/theme_music_service.dart.

Sanity-checks the synthesis math (peak, RMS, loop seam, harmony) and writes a
preview wav so the waltz can be listened to outside the app.
"""

import math
import struct
import wave

SAMPLE_RATE = 22050
BPM = 132
TOTAL_BEATS = 48.0
TAIL_SECONDS = 1.6

# (midi, startBeat, lengthInBeats)
MELODY = [
    (71, 0, 1), (76, 1, 1), (79, 2, 1),
    (78, 3, 2), (76, 5, 1),
    (83, 6, 1), (81, 7, 2),
    (78, 9, 3),
    (76, 12, 1), (79, 13, 1), (81, 14, 1),
    (79, 15, 2), (76, 17, 1),
    (75, 18, 3),
    (83, 24, 1), (88, 25, 1), (91, 26, 1),
    (90, 27, 2), (88, 29, 1),
    (95, 30, 1), (93, 31, 2),
    (90, 33, 3),
    (88, 36, 1), (91, 37, 1), (93, 38, 1),
    (91, 39, 2), (88, 41, 1),
    (88, 42, 3),
]

# (rootMidi, voice1, voice2, voice3, startBeat) — two bars of 3/4 each
HARMONY = [
    (40, 52, 55, 59, 0),   # Em
    (35, 54, 59, 62, 6),   # Bm
    (36, 55, 60, 64, 12),  # C
    (35, 51, 54, 57, 18),  # B7
    (40, 52, 55, 59, 24),  # Em
    (35, 54, 59, 62, 30),  # Bm
    (36, 55, 60, 64, 36),  # C
    (40, 52, 55, 59, 42),  # Em
]

PARTIALS = [
    (1.0, 1.00, 1.00),
    (2.0, 0.42, 1.70),
    (3.01, 0.20, 2.60),
    (4.98, 0.11, 3.40),
    (6.94, 0.05, 4.30),
]

# Pitch classes of E natural minor, plus D# (harmonic-minor leading tone).
E_MINOR_PCS = {4, 6, 7, 9, 11, 0, 2}
LEADING_TONE_PC = 3  # D#
NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


def freq(midi):
    return 440.0 * (2 ** ((midi - 69) / 12.0))


def render_celesta(out, note, spb):
    midi, beat, beats = note
    gain = 0.85
    start = round(beat * spb * SAMPLE_RATE)
    length = round((beats * spb + 1.4) * SAMPLE_RATE)
    f = freq(midi)
    for i in range(length):
        idx = start + i
        if idx >= len(out):
            break
        t = i / SAMPLE_RATE
        attack = t / 0.006 if t < 0.006 else 1.0
        s = 0.0
        for mult, amp, dec in PARTIALS:
            s += amp * math.exp(-t * dec * 1.15) * math.sin(2 * math.pi * f * mult * t)
        out[idx] += s * attack * gain * 0.22


def render_harp(out, midi, beat, beats, gain, spb):
    start = round(beat * spb * SAMPLE_RATE)
    length = round((beats * spb + 0.9) * SAMPLE_RATE)
    f = freq(midi)
    for i in range(length):
        idx = start + i
        if idx >= len(out):
            break
        t = i / SAMPLE_RATE
        attack = t / 0.012 if t < 0.012 else 1.0
        decay = math.exp(-t * 1.5)
        s = (
            math.sin(2 * math.pi * f * t)
            + 0.34 * math.exp(-t * 2.4) * math.sin(4 * math.pi * f * t)
            + 0.14 * math.exp(-t * 3.2) * math.sin(6 * math.pi * f * t)
        )
        out[idx] += s * attack * decay * gain * 0.22


def apply_reverb(buf):
    wet = [0.0] * len(buf)
    for ms in (37.0, 53.0, 71.0, 97.0):
        d = round(ms / 1000.0 * SAMPLE_RATE)
        if d <= 0 or d >= len(buf):
            continue
        for i in range(d, len(buf)):
            wet[i] += (buf[i - d] + wet[i - d] * 0.34) * 0.34 * 0.5
    for i in range(len(buf)):
        buf[i] = buf[i] + wet[i] * 0.30


def normalize(buf, peak):
    m = max(abs(v) for v in buf)
    if m < 1e-9:
        return
    scale = peak / m
    for i in range(len(buf)):
        buf[i] *= scale


def chord_at(beat):
    """The (root, voices) sounding at a given beat, or None."""
    for root, a, b, c, start in HARMONY:
        if start <= beat < start + 6:
            return root, (a, b, c)
    return None


def check_harmony():
    """Every melody note should belong to E minor (D# allowed only over B7)."""
    problems = []
    checked_leading_tones = 0
    for midi, beat, _ in MELODY:
        pc = midi % 12
        if pc in E_MINOR_PCS:
            continue
        if pc == LEADING_TONE_PC:
            chord = chord_at(beat)
            if chord is not None and chord[1] == (51, 54, 57):  # B7
                checked_leading_tones += 1
                continue
        problems.append(f"beat {beat}: {NAMES[pc]}{midi // 12 - 1}")
    return problems, checked_leading_tones


def check_melody_range():
    lows = [m for m, _, _ in MELODY]
    return min(lows), max(lows)


def main():
    spb = 60.0 / BPM
    loop_samples = round(TOTAL_BEATS * spb * SAMPLE_RATE)
    tail_samples = round(TAIL_SECONDS * SAMPLE_RATE)
    buf = [0.0] * (loop_samples + tail_samples)

    for note in MELODY:
        render_celesta(buf, note, spb)

    for root, a, b, c, start_beat in HARMONY:
        for bar in range(2):
            bar_start = start_beat + bar * 3
            render_harp(buf, root, bar_start, 2.6, 0.34, spb)
            for beat in (1, 2):
                for v in (a, b, c):
                    render_harp(buf, v, bar_start + beat, 1.1, 0.10, spb)

    raw_peak = max(abs(v) for v in buf)
    apply_reverb(buf)

    # Fold the ring-out past the loop point back over the opening, so the decay
    # of the final chord carries into the next repetition instead of being cut.
    for i in range(tail_samples):
        buf[i] += buf[loop_samples + i]
    buf = buf[:loop_samples]

    normalize(buf, 0.72)

    duration = loop_samples / SAMPLE_RATE
    peak = max(abs(v) for v in buf)
    rms = math.sqrt(sum(v * v for v in buf) / len(buf))

    # A clean loop means the last sample flows into the first without a step.
    seam_step = abs(buf[-1] - buf[0])
    # Compare against the largest step anywhere inside the track.
    max_internal_step = max(abs(buf[i + 1] - buf[i]) for i in range(0, len(buf) - 1, 7))

    silent_run = 0
    longest_silence = 0
    for v in buf:
        if abs(v) < 0.001:
            silent_run += 1
            longest_silence = max(longest_silence, silent_run)
        else:
            silent_run = 0

    lo, hi = check_melody_range()
    problems, leading_tones = check_harmony()

    print(f"duration       : {duration:.2f}s ({TOTAL_BEATS / 3:.0f} bars of 3/4)")
    print(f"notes          : {len(MELODY)} melody, {len(HARMONY) * 2 * 7} accompaniment")
    print(f"melody range   : {NAMES[lo % 12]}{lo // 12 - 1} to {NAMES[hi % 12]}{hi // 12 - 1}")
    print(f"raw peak       : {raw_peak:.3f} (pre-normalize; >1.0 risks clipping)")
    print(f"final peak     : {peak:.3f}")
    print(f"rms            : {rms:.4f}")
    print(f"loop seam step : {seam_step:.5f}  (max internal step {max_internal_step:.5f})")
    print(f"longest gap    : {longest_silence / SAMPLE_RATE:.2f}s")
    print(f"out-of-key     : {problems if problems else 'none'}")
    print(f"D# over B7     : {leading_tones} (allowed leading tones)")
    # A vacuous key check would be worse than none, so prove it can fail.
    saved = MELODY[:]
    MELODY.append((73, 0, 1))  # C#, foreign to E natural minor
    bad, _ = check_harmony()
    MELODY[:] = saved
    print(f"self-test      : {'ok, checker rejects foreign notes' if bad else 'BROKEN — checker accepts anything'}")

    with wave.open("theme_preview.wav", "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767)) for v in buf
        ))
    print("wrote theme_preview.wav")


if __name__ == "__main__":
    main()
