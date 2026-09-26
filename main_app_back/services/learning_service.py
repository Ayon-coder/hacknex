"""AI Learning interaction system service."""

import asyncio
import hashlib
import json
import re
from fastapi import HTTPException
from config import GEMINI_API_KEY, ELEVENLABS_API_KEY, audio_cache, text_cache, inflight, evict_if_full, log
from models.learning import (
    LearningRequest,
    MCQuestion,
    LearningContentResponse,
    TTSRequest,
    TTSResponse,
)
from services.gemini_service import call_gemini
from services.elevenlabs_service import call_elevenlabs, tts_model_candidates


async def synthesize_audio(key: str, text: str) -> bytes:
    """Synthesizes speech via ElevenLabs for a given text and caches the audio bytes."""
    if key in audio_cache:
        return audio_cache[key]

    log.info("🔊 [LearningService]: Starting ElevenLabs TTS synthesis for key %s (len: %d)", key, len(text))
    try:
        last_error = None
        for model_id in tts_model_candidates():
            try:
                audio = await call_elevenlabs(text, model_id)
                evict_if_full(audio_cache)
                audio_cache[key] = audio
                log.info("✅ [LearningService]: Cached %d audio bytes for key %s", len(audio), key)
                return audio
            except Exception as exc:
                last_error = exc
                log.warning("ElevenLabs model %s failed for %s: %s", model_id, key, exc)

        if last_error:
            raise last_error
    except Exception as exc:
        log.error("❌ [LearningService]: ElevenLabs TTS synthesis failed for key %s: %s", key, exc)

    raise RuntimeError("ElevenLabs TTS synthesis failed")


# ---------------------------------------------------------------------------
# Subject-Specific Curriculum Ladders
# Each subject has progression tiers keyed by student_level.
# ---------------------------------------------------------------------------
_SUBJECT_CURRICULA: dict[str, list[dict]] = {
    "Derivation": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Rate of Change Intuition", "Speed vs Distance Graphs", "Slope of Straight Lines", "Rise over Run", "Constant Rule: d/dx[c]=0", "Linear Derivative: d/dx[x]=1"], "style": "Foundational 1-step concepts. Use speedometers, runners, and straight line slopes."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Power Rule with Coefficients: d/dx[a*x^n]", "Polynomial Derivatives (3x^2 - 8x + 5)", "Slope of Tangent at a Specific Point (x = x0)", "Instantaneous Velocity from Quadratic Position s(t)", "Derivatives of Sin(x) and Cos(x)"], "style": "Substantially harder than Level 1. Requires real multi-step computation, higher coefficients, and calculating numerical slopes at specific coordinates."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Product Rule for Derivatives: (uv)' = u'v + uv'", "Quotient Rule: (u/v)'", "Chain Rule for Composite Functions", "Finding Critical Points where f'(x)=0", "Local Maxima & Minima on Curves"], "style": "Multi-step calculus techniques. Combine product/quotient/chain rules and solve for critical values."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Second Derivative & Concavity Test", "Inflection Points", "Related Rates Word Problems", "Implicit Differentiation", "Optimization of Cost and Area"], "style": "Rigorous calculus problem solving with practical geometric and physical optimization."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["L'Hôpital's Rule & Indeterminate Forms", "Taylor & Maclaurin Series", "Partial Derivatives in 3D", "Gradient Vector & Directional Derivative", "Optimization with Constraints (Lagrange Multipliers)"], "style": "Use formal calculus notation and multivariable optimization."},
    ],
    "Integration": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Accumulation Concept (Speed to Distance)", "Area Under a Horizontal Line", "Rectangle Approximations", "Antiderivative Concept", "Integral of Constants: integral(k dx) = kx + C"], "style": "Use water filling a tank or an odometer accumulating distance. Simple 1-step antiderivatives."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Reverse Power Rule with Coefficients: integral(a*x^n dx)", "Integrating Polynomials (3x^2 + 4x - 5)", "Basic Definite Integrals with Limits (from 0 to 2)", "Integrals of Sin(x) and Cos(x)", "Area Under a Line Segment"], "style": "Substantially harder than Level 1. Requires evaluating reverse power rule with coefficients and calculating definite integral areas."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["U-Substitution Method", "Integration by Parts: uv - integral v du", "Area Between Two Curves", "Volumes of Revolution (Disk & Washer)", "Average Value of a Function"], "style": "Walk through substitution variable changes and differential transformations."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Partial Fraction Decomposition", "Trigonometric Substitution", "Improper Integrals to Infinity", "Arc Length of Curves", "Numerical Integration (Simpson's Rule)"], "style": "Use advanced analytic integration techniques and multi-step methods."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Double Integrals over 2D Regions", "Line Integrals & Vector Fields", "Green's Theorem", "Stokes' Theorem", "Divergence Theorem"], "style": "Use rigorous analytic integration techniques and physical applications."},
    ],
    "Trigonometry": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Right-Angled Triangles", "Hypotenuse, Opposite, Adjacent", "SOH-CAH-TOA Definitions", "Pythagorean Theorem: a^2 + b^2 = c^2", "Measuring Angles in Degrees"], "style": "Use triangles on buildings, shadows, and ladders against walls."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Finding Missing Sides with SOH-CAH-TOA", "Standard Angles (30, 45, 60, 90 degrees)", "Radians vs Degrees (pi = 180 deg)", "Unit Circle Coordinates (cos theta, sin theta)", "Fundamental Pythagorean Identity: sin^2 + cos^2 = 1"], "style": "Substantially harder than Level 1. Requires calculating exact missing ratios, radians conversions, and Pythagorean identities."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Law of Sines", "Law of Cosines", "Double-Angle Formulas: sin(2A), cos(2A)", "Reciprocal Functions: sec, csc, cot", "Solving Trigonometric Equations"], "style": "Solve non-right triangles and simplify trigonometric identities."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Sum and Difference Formulas", "Inverse Trigonometric Functions", "Amplitude, Period and Phase Shift of Waves", "Half-Angle Formulas", "Trigonometric Form of Complex Numbers"], "style": "Advanced trigonometric identities and wave mechanics."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Euler's Formula: e^(ix) = cos(x) + i sin(x)", "De Moivre's Theorem", "Hyperbolic Functions: sinh, cosh", "Fourier Analysis Intuition", "Spherical Trigonometry"], "style": "Connect complex exponentials to rotation and trigonometric harmonics."},
    ],
    "Algebra": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Variables as Placeholders", "Evaluating Expressions with 1 Variable", "Combining Like Terms", "1-Step Equations: x + a = b", "1-Step Equations: ax = b"], "style": "Think of equations as a balanced scale: simple 1-step variable isolation."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["2-Step Equations: ax + b = c", "Distributive Property in Equations", "Equations with Variables on Both Sides", "Factoring Quadratic Trinomials: x^2 + bx + c = 0", "Slope-Intercept Form: y = mx + b"], "style": "Substantially harder than Level 1. Multi-step variable manipulation and quadratic factoring."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Systems of 2 Equations (Substitution & Elimination)", "The Quadratic Formula & Discriminant", "Graphing Parabolas (Vertex & Intercepts)", "Exponent Rules & Negative Exponents", "Linear Inequalities in 2 Variables"], "style": "Connect algebraic roots to x-intercepts of parabolas on a Cartesian grid."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Polynomial Long Division & Remainder Theorem", "Logarithm Rules & Equations", "Rational Expressions & Equations", "Arithmetic & Geometric Sequences", "Binomial Theorem"], "style": "Derive exponential and logarithmic formulas step by step."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Matrices & Determinants", "Cramer's Rule for Systems", "Complex Numbers: a + bi & Conjugates", "Eigenvalues & Linear Transformations", "Abstract Vector Spaces"], "style": "Use vector-matrix representations and formal algebraic structures."},
    ],
    "Geometry": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["2D Shapes & Polygons", "Perimeter of Rectangles & Triangles", "Area of Rectangles & Squares", "Types of Angles (Acute, Right, Obtuse)", "Triangle Angle Sum (180 degrees)"], "style": "Use floor tiles, fences, and simple grid shapes."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Area of Triangles & Parallelograms", "Circumference & Area of Circles (2*pi*r, pi*r^2)", "Pythagorean Theorem in 2D (a^2 + b^2 = c^2)", "Coordinate Geometry: Distance & Midpoint Formulas", "Angles on Parallel Lines & Transversals"], "style": "Substantially harder than Level 1. Requires multi-step area calculations, circle formulas, and coordinate distance calculations."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Surface Area & Volume of Cylinders and Prisms", "Similar and Congruent Triangles", "Circle Theorems (Inscribed Angles, Tangents)", "2D Vectors: Magnitude and Direction", "Geometric Transformations (Reflections, Rotations)"], "style": "Plot points on the (x, y) coordinate plane to calculate lengths, angles, and vector magnitudes."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Equations of Circles: (x-h)^2 + (y-k)^2 = r^2", "Dot Product of Vectors", "Surface Area and Volume of Spheres and Cones", "Coordinate Proofs", "Non-Right Triangle Trigonometry"], "style": "Use displacement arrows, components [vx, vy], and coordinate transformations."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["3D Vectors & Cross Product", "Vector Equations of Lines and Planes", "Conic Sections (Parabolas, Ellipses, Hyperbolas)", "Non-Euclidean Geometry Concepts", "Projective Geometry Principles"], "style": "Use 3D coordinate space [x, y, z] and normal vectors."},
    ],
    "Arithmetic": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Place Value & Large Numbers", "Mental Addition & Subtraction", "Multiplication Tables (1 to 12)", "Division with Remainders", "Even, Odd & Multiples"], "style": "Use counting puzzles and rapid mental math patterns."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Order of Operations (PEMDAS/BODMAS)", "Prime Numbers & Prime Factorization Trees", "Greatest Common Factor (GCF) & Least Common Multiple (LCM)", "Fractions: Addition & Subtraction with Unlike Denominators", "Decimals & Percentages Conversion"], "style": "Substantially harder than Level 1. Multi-step brackets, GCF/LCM calculation, and unlike fraction arithmetic."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Integer Exponents & Powers of 10", "Square Roots & Cube Roots", "Scientific Notation & Operations", "Ratios, Rates & Proportional Reasoning", "Multi-Step Word Problems"], "style": "Calculate expressions systematically using PEMDAS brackets, roots, and exponents."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Modular Arithmetic (Clock Math)", "Euclidean Algorithm for GCF", "Sequences: Arithmetic & Geometric nth-term", "Factorials & Permutations: nPr and nCr", "Divisibility Proofs"], "style": "Use clock faces for modular math and systematic factorials."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Fermat's Little Theorem", "Prime Number Distribution & Sieve of Eratosthenes", "Diophantine Equations", "Cryptographic Math & RSA Basics", "Proof by Mathematical Induction"], "style": "Use formal number theory definitions and modular congruence proofs."},
    ],
    "Mathematics": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Place Value & Mental Math", "Addition & Subtraction", "Times Tables", "Basic Division", "Fractions Introduction"], "style": "Concrete, 1-step numbers and visual quantities."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Pre-Algebra & 2-Step Equations", "Order of Operations (PEMDAS)", "Area & Perimeter of Complex Shapes", "Fractions Arithmetic with Unlike Denominators", "Percentages & Ratios"], "style": "Substantially harder than Level 1. Multi-step problem solving, algebra foundations, and arithmetic with unlike fractions."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Linear Equations & Systems", "Quadratic Equations & Factoring", "Coordinate Geometry & Slopes", "Trigonometry Basics (SOH-CAH-TOA)", "Probability & Data Analysis"], "style": "Formal algebraic manipulation and coordinate plane reasoning."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Functions & Transformations", "Exponential & Logarithmic Functions", "Sequences & Series", "Matrices & Vectors", "Permutations & Combinations"], "style": "Advanced mathematical modeling and multi-topic synthesis."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Limits & Derivatives", "Integration & Area Under Curves", "Differential Equations", "Complex Analysis", "Abstract Algebra"], "style": "University-level mathematical depth and rigorous proofs."},
    ],
    "Programming": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["What is a Program?", "Variables & Data Types", "Print Statements & Console Output", "Simple If Conditionals", "Basic Function Calling"], "style": "Use everyday analogies: variables as labelled boxes, simple single-line commands."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["For Loops & While Loops", "Nested Loops & Iteration", "Arrays & Lists Indexing", "Function Parameters & Return Values", "String Manipulation & Slicing"], "style": "Substantially harder than Level 1. Multi-line code tracing, loop index tracking, and function return values."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Dictionaries & Hash Maps", "Recursion vs Iteration", "Sorting Algorithms (Bubble, Merge)", "Object-Oriented Programming (Classes & Objects)", "Exception Handling (Try/Catch)"], "style": "Compare algorithmic approaches, show time complexity trade-offs, and class structures."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Stacks, Queues & Linked Lists", "Binary Trees & Traversal", "Big-O Time & Space Complexity", "REST APIs & JSON Parsing", "Database Queries (SQL Basics)"], "style": "Software engineering patterns and system efficiency."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Dynamic Programming", "Graph Algorithms (Dijkstra, BFS/DFS)", "Concurrency & Multi-Threading", "Compiler Design & Bytecode", "Distributed Systems Architecture"], "style": "Rigorous computer science theory and production-grade architectures."},
    ],
    "Physics": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["What is Matter?", "States of Matter", "Speed & Distance Intuition", "Gravity Introduction", "Light & Shadow"], "style": "Simple toy-car and falling-apple examples. Direct 1-step questions."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Newton's Laws of Motion (F = m*a)", "Friction & Normal Force", "Kinetic & Potential Energy Calculations (KE = 1/2*m*v^2)", "Work & Power Equations (W = F*d)", "Speed, Velocity & Acceleration Calculations"], "style": "Substantially harder than Level 1. Requires numerical calculations using physics formulas F=ma and KE=1/2*m*v^2."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Momentum & Conservation of Momentum", "Waves: Frequency, Wavelength & Speed (v = f*lambda)", "Optics: Snell's Law & Refraction", "Electric Circuits: Ohm's Law (V = I*R)", "Thermodynamics & Heat Transfer"], "style": "Multi-variable physics formulas and circuit analysis."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Circular Motion & Centripetal Force", "Electric Fields & Coulomb's Law", "Magnetic Fields & Induction", "Special Relativity (Time Dilation)", "Quantum Physics Foundations"], "style": "Vector mechanics and modern physics principles."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["General Relativity", "Particle Physics & Standard Model", "Quantum Field Theory", "Astrophysics & Black Holes", "Cosmological Expansion"], "style": "University-level mathematical physics frameworks."},
    ],
    "Chemistry": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["What are Atoms?", "Elements & the Periodic Table", "Solids, Liquids, Gases", "Physical vs Chemical Changes", "Lab Safety Rules"], "style": "Cooking and everyday household material examples."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Atomic Structure (Protons, Neutrons, Electrons)", "Chemical Bonds: Ionic vs Covalent", "Writing Chemical Formulas", "Balancing Simple Equations", "Acids, Bases & the pH Scale"], "style": "Substantially harder than Level 1. Balancing chemical equations and calculating subatomic particles."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Stoichiometry & The Mole Concept", "Molar Mass Calculations", "Exothermic vs Endothermic Reactions", "Gas Laws (PV = nRT)", "Solutions, Solute & Molarity"], "style": "Quantitative chemical calculations and mole ratio conversions."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Organic Chemistry & Functional Groups", "Reaction Rates & Chemical Equilibrium", "Redox Reactions & Electrochemistry", "Enthalpy and Gibbs Free Energy", "Acid-Base Titration Curves"], "style": "Mechanisms, reaction coordinate diagrams, and equilibrium constants."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Quantum Chemistry & Orbitals", "Spectroscopy Analysis", "Polymer & Biochemistry", "Chemical Thermodynamics", "Inorganic Coordination Complexes"], "style": "Advanced chemical theory and research context."},
    ],
    "History": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["What is History?", "Timelines & Chronology", "Ancient Civilizations Overview", "Famous Inventions", "Historical Artifacts"], "style": "Simple storytelling and memorable narrative milestones."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Ancient Egypt & Mesopotamia Governance", "Greek City-States: Athens vs Sparta", "The Roman Republic & Empire", "The Silk Road & Trade Networks", "The Middle Ages & Feudalism"], "style": "Substantially harder than Level 1. Cause-and-effect comparisons and structural analysis."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["The Renaissance & Scientific Revolution", "The Age of Exploration & Colonialism", "The Industrial Revolution & Urbanization", "The American & French Revolutions", "World War I Causes & Outcomes"], "style": "Deep geopolitical analysis, primary source evidence, and socio-economic consequences."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["World War II & The Holocaust", "The Cold War & Nuclear Diplomacy", "Decolonization & Independence Movements", "International Organizations (UN, League of Nations)", "Historiography & Conflicting Sources"], "style": "Critical source evaluation and multi-perspective historical debate."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Philosophy of History", "Comparative Civilizations Theory", "Economic History & Global Trade", "Post-Colonial Global Politics", "Modern Geopolitical Flashpoints"], "style": "Academic discourse and global historiographical critique."},
    ],
    "Astronomy": [
        {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["The Solar System Overview", "The Sun, Earth & Moon", "Stars vs Planets", "Day, Night & Seasons", "The Moon's Phases"], "style": "Everyday sky-watching and foundational celestial bodies."},
        {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Planetary Characteristics (Terrestrial vs Gas Giants)", "Asteroid Belt & Kuiper Belt", "Gravity & Orbital Periods", "Telescopes & Optical Instruments", "History of Human Spaceflight"], "style": "Substantially harder than Level 1. Planetary data comparisons, gravity principles, and space exploration milestones."},
        {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Stellar Evolution (Nebula to Supernova)", "Hertzsprung-Russell (H-R) Diagram", "Black Holes & Event Horizons", "The Milky Way & Galaxy Types", "Cosmic Distances & Light-Years"], "style": "Stellar physics, light-year calculations, and life cycles of stars."},
        {"levels": (4, 4), "tier": "Master (Level 4)", "topics": ["Exoplanet Detection Methods (Transit, Radial Velocity)", "Cosmic Microwave Background (CMB)", "Dark Matter & Dark Energy", "Neutron Stars & Pulsars", "General Relativity & Gravitational Lensing"], "style": "Modern astrophysical instruments and cosmic evolutionary models."},
        {"levels": (5, 99), "tier": "Expert (Level 5+)", "topics": ["Quantum Cosmology & Inflation", "Supermassive Black Hole Dynamics", "Hawking Radiation & Thermodynamics", "Stellar Nucleosynthesis Pathways", "Multiverse & High-Energy Astrophysics"], "style": "University-level theoretical astrophysics and cosmological mathematics."},
    ],
}

# Default fallback for unknown subjects
_DEFAULT_CURRICULA = [
    {"levels": (1, 1), "tier": "Beginner (Level 1)", "topics": ["Core Concepts & Definitions", "Basic Terminology", "Foundational Principles"], "style": "Keep simple, concrete, 1-step."},
    {"levels": (2, 2), "tier": "Intermediate (Level 2 - Harder)", "topics": ["Applied Principles", "Multi-Step Problem Solving", "Analytical Comparisons"], "style": "Substantially harder than Level 1, requiring calculations and multi-step steps."},
    {"levels": (3, 3), "tier": "Advanced (Level 3)", "topics": ["Advanced Theory", "Critical Synthesis", "Complex Problem Solving"], "style": "Multi-concept theorems and advanced problem sets."},
    {"levels": (4, 99), "tier": "Master (Level 4+)", "topics": ["Frontier Research", "Formal Proofs", "Expert Analysis"], "style": "Rigorous analysis and complex examples."},
]


def _get_curriculum_tier(req: LearningRequest) -> dict:
    """Return the curriculum tier dict matching the student_level for this subject."""
    subj = req.subject.strip()
    b_name = req.building_name.strip()
    target_str = f"{subj} {b_name}".lower()

    if "derivat" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Derivation")
    elif "integrat" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Integration")
    elif "trig" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Trigonometry")
    elif "algebra" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Algebra")
    elif "geometry" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Geometry")
    elif "arithmetic" in target_str or "number" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Arithmetic")
    elif "math" in target_str:
        ladder = _SUBJECT_CURRICULA.get("Mathematics")
    else:
        ladder = _SUBJECT_CURRICULA.get(subj)
        if ladder is None:
            for key, val in _SUBJECT_CURRICULA.items():
                if key.lower() in subj.lower() or subj.lower() in key.lower():
                    ladder = val
                    break
    if ladder is None:
        ladder = _DEFAULT_CURRICULA
    for tier in ladder:
        lo, hi = tier["levels"]
        if lo <= req.student_level <= hi:
            return tier
    return ladder[-1]  # cap at highest tier


def _level_label(lvl: int) -> str:
    if lvl == 1:   return "Level 1: Beginner student (Foundational 1-step concepts & definitions)"
    if lvl == 2:   return "Level 2: Intermediate student (Significantly harder than Level 1! Requires real multi-step calculations, higher coefficients, evaluating slope/rates at specific points)"
    if lvl == 3:   return "Level 3: Advanced student (Harder than Level 2! Multi-concept rules, product/quotient/chain methods, critical points)"
    if lvl == 4:   return "Level 4: Master student (Higher-order analysis, optimization, implicit differentiation)"
    return f"Level {lvl}: Expert / University-level rigor"


def build_learning_prompt(req: LearningRequest) -> str:
    subj = req.subject.strip() or "General Knowledge"
    b_name = req.building_name.strip() or "Academy Tower"
    lvl = req.student_level
    tier_info = _get_curriculum_tier(req)
    tier_name = tier_info["tier"]
    topic_list = ", ".join(tier_info["topics"])
    style_hint = tier_info["style"]
    level_desc = _level_label(lvl)
    specific_topic = f"\nSPECIFIC TOPIC TO TEACH THIS SESSION: {req.topic}" if req.topic else f"\nChoose ONE specific topic from this curriculum list for this session: [{topic_list}]"

    target_lower = f"{subj} {b_name}".lower()
    is_math = any(k in target_lower for k in ["math", "derivat", "integrat", "trig", "algebra", "geometry", "arithmetic", "calculus"])

    math_constraint = ""
    if is_math:
        branch_guidance = ""
        if "derivat" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: DERIVATION & DIFFERENTIAL CALCULUS (LEVEL 1: BEGINNER).
- Questions MUST test foundational concepts: rates of change, speed from distance, slope of a straight line, constant rule d/dx[c]=0, and linear rule d/dx[x]=1.
- Examples of Level 1 questions: "What is d/dx[15]?", "For y = 4x + 7, what is the slope (derivative)?", "If s(t) = 50t, what is the velocity s'(t)?", "Geometrically, what does a derivative represent at any point?"."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: DERIVATION & DIFFERENTIAL CALCULUS (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST be real multi-step mathematical calculations:
  * Power rule with non-trivial coefficients: d/dx[a*x^n] = a*n*x^(n-1), e.g. d/dx[5x^3] or d/dx[4x^4].
  * Differentiating multi-term polynomials: e.g. d/dx[3x^2 - 8x + 6].
  * Evaluating the slope of tangent to a curve AT A SPECIFIC GIVEN POINT x = x0: e.g. "What is the slope of y = 2x^2 + x at x = 3?" (Requires calculating y' = 4x + 1, then plugging in x=3 to get 13).
  * Basic derivatives of trigonometric functions: d/dx[sin(x)] = cos(x), d/dx[cos(x)] = -sin(x).
- DO NOT ask trivial 1-step recall questions or constant rules! Level 2 MUST challenge the student with actual calculation."""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: DERIVATION & DIFFERENTIAL CALCULUS (LEVEL 3+: ADVANCED).
- ALL 4 questions MUST be advanced calculus problems: product rule (uv)' = u'v + uv', quotient rule, chain rule for composite functions d/dx[(ax+b)^n], or finding critical points where f'(x) = 0.
- Examples: "Using the product rule, find d/dx[x * cos(x)]", "Find the critical points of f(x) = x^3 - 3x", "Find d/dx[(2x+1)^4]"."""
        elif "integrat" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: INTEGRATION (LEVEL 1: BEGINNER).
- Questions MUST test foundational accumulation and antiderivative intuition: integral of constant k is kx + C, reversing simple derivatives, area intuition under a horizontal line."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: INTEGRATION (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST require calculation: reverse power rule with coefficients (e.g. integral of 6x^2 dx = 2x^3 + C), integrating polynomials (e.g. integral of 4x^3 + 6x - 2 dx), computing basic definite integrals with boundary limits (e.g. integral from 0 to 2 of 3x^2 dx = 8), and integrals of sin(x) and cos(x).
- DO NOT ask trivial Level 1 recall questions!"""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: INTEGRATION (LEVEL 3+: ADVANCED).
- ALL 4 questions MUST be advanced integral problems: u-substitution, integration by parts, area between two curves, and definite integrals with trigonometric boundaries."""
        elif "trig" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: TRIGONOMETRY (LEVEL 1: BEGINNER).
- Questions test SOH-CAH-TOA definitions, right triangle sides (hypotenuse, opposite, adjacent), and basic angles."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: TRIGONOMETRY (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST require calculation: finding missing sides using SOH-CAH-TOA ratios, exact values of standard angles (30, 45, 60, 90 deg), converting between degrees and radians (pi = 180 deg), unit circle coordinates (cos theta, sin theta), and applying sin^2(x) + cos^2(x) = 1."""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: TRIGONOMETRY (LEVEL 3+: ADVANCED).
- Questions test Law of Sines, Law of Cosines, double-angle formulas sin(2A) and cos(2A), reciprocal functions (sec, csc, cot), and solving trig equations."""
        elif "algebra" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ALGEBRA (LEVEL 1: BEGINNER).
- Questions test 1-step equations (x + a = b, ax = b) and combining like terms."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ALGEBRA (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST require multi-step solving: 2-step equations (ax + b = c), distributive property, equations with variables on both sides, factoring quadratic trinomials (x^2 + bx + c = 0), and slope-intercept form (y = mx + b)."""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ALGEBRA (LEVEL 3+: ADVANCED).
- Questions test systems of equations, the quadratic formula, graphing parabolas, and exponent laws."""
        elif "geometry" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: GEOMETRY (LEVEL 1: BEGINNER).
- Questions test perimeter and area of rectangles, types of angles, and triangle angle sum (180 deg)."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: GEOMETRY (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST require calculation: area of triangles and parallelograms, circumference and area of circles (2*pi*r, pi*r^2), Pythagorean theorem in 2D (a^2 + b^2 = c^2), and coordinate distance and midpoint formulas."""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: GEOMETRY (LEVEL 3+: ADVANCED).
- Questions test 3D volume and surface area, 2D vector magnitudes, and circle theorems."""
        elif "arithmetic" in target_lower or "number" in target_lower:
            if lvl == 1:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ARITHMETIC (LEVEL 1: BEGINNER).
- Questions test place value, mental addition/subtraction, times tables (1 to 12), and simple division with remainders."""
            elif lvl == 2:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ARITHMETIC (LEVEL 2: INTERMEDIATE - SIGNIFICANTLY HARDER THAN LEVEL 1).
- ALL 4 questions MUST require multi-step calculation: order of operations (PEMDAS with brackets and multiplication), prime factorization trees, Greatest Common Factor (GCF) and Least Common Multiple (LCM), and adding/subtracting fractions with unlike denominators."""
            else:
                branch_guidance = """- SPECIALIZED HOUSE DOMAIN: ARITHMETIC (LEVEL 3+: ADVANCED).
- Questions test exponent laws, square roots, scientific notation, and ratios and proportions."""
        else:
            branch_guidance = f"""- SPECIALIZED HOUSE DOMAIN: MATHEMATICS (LEVEL {lvl}).
- ALL 4 questions MUST be concrete numerical calculations calibrated strictly to Level {lvl} difficulty."""

        math_constraint = f"""
STRICT MATHEMATICS HOUSE CONSTRAINTS:
- You are in the {b_name} dedicated to {subj}.
- EVERY QUESTION MUST BE A CONCRETE, SOLVABLE MATHEMATICAL PROBLEM, EQUATION, CALCULATION, OR FORMULA PUZZLE.
- ABSOLUTELY FORBIDDEN: NEVER ask generic study questions like "What is the best way to learn?", "Why is practice useful?", "How should mistakes be viewed?", or general study tips.
{branch_guidance}

CRITICAL TOUGHNESS REQUIREMENT (LEVEL {lvl}):
- The student is at BUILDING LEVEL {lvl}.
- The toughness of the questions MUST strictly match and scale with Level {lvl}!
- LEVEL 2 MUST BE SUBSTANTIALLY HARDER than Level 1:
  * Do NOT ask trivial 1-step recall or nursery-level questions.
  * Level 1 covers basic rules (e.g. constant rule d/dx[c]=0, slope definition).
  * Level 2 MUST require actual multi-step calculations (e.g. power rule with coefficients like d/dx[5x^3 - 4x^2 + 7], calculating slope at a specific point, evaluating rates of change, standard derivatives of sin/cos).
  * Level 3 MUST feature advanced techniques (product rule, quotient rule, chain rule, critical points).
- The 4 questions MUST strictly progress from easiest to hardest within Level {lvl}:
  * Q1: Level {lvl} Warmup (direct application of Level {lvl} concept)
  * Q2: Level {lvl} Multi-step problem
  * Q3: Level {lvl} Deeper problem-solving
  * Q4: Level {lvl} Challenge / synthesis problem
"""
    else:
        math_constraint = f"""
STRICT SUBJECT CONSTRAINTS (LEVEL {lvl}):
- All questions MUST test actual knowledge, mechanisms, and problems of {subj} at Level {lvl}.
- Level 2 questions MUST be noticeably harder than Level 1, requiring multi-step thinking and deeper mechanics.
- ABSOLUTELY FORBIDDEN: Do NOT ask generic study questions like "What is the best way to learn?", "Why is practice useful?", etc.
"""

    return f"""You are the Master Instructor at the {b_name} in KnowledgeVerse AI Academy.

You MUST generate content EXCLUSIVELY about {subj}. Do NOT drift into any other subject.
{math_constraint}
STUDENT PROFILE:
- Subject: {subj}
- Student Level: {lvl} ({level_desc})
- Curriculum Tier: {tier_name}
- Available topics for this tier: [{topic_list}]{specific_topic}

CURRICULUM STYLE GUIDANCE: {style_hint}

Requirements for TOPIC EXPLANATION:
- Choose exactly ONE specific {subj} topic appropriate for a {level_desc}.
- Write 100-140 words ONLY about that {subj} topic. No other subject.
- Difficulty MUST match level {lvl}: {'very simple language, concrete objects, no jargon' if lvl <= 2 else 'simple language with one analogy' if lvl <= 4 else 'clear with some technical terms explained' if lvl <= 6 else 'technical, assume prior knowledge, use notation' if lvl <= 8 else 'rigorous, formal, university-level depth'}.
- Use a vivid, memorable real-world analogy that directly relates to {subj}.
- Warm, inspiring, KnowledgeVerse Academy tone.

Requirements for QUESTIONS (ALL 4 questions MUST be about {subj} only):
- EXACTLY 4 multiple-choice questions about the explained {subj} topic.
- Each question MUST have EXACTLY 4 option strings.
- Difficulty progression: Q1 easiest (recall/warmup), Q2 moderate (application), Q3 harder (problem-solving), Q4 hardest (puzzle/analysis) — all calibrated to student level {lvl}.
- "correct_index" MUST be the exact integer index (0, 1, 2, or 3) where the correct answer is located in "options". Verify that options[correct_index] is mathematically correct!
- Distribute the correct index across questions (e.g., Q1 has correct index 1, Q2 has 3, Q3 has 0, Q4 has 2). Do NOT set all to 0.
- Provide a brief 1-sentence explanation of why options[correct_index] is correct.
- Questions MUST test actual {subj} skills — NEVER generic study habits or meta-learning questions.
- FORMATTING: Use plain text math symbols (e.g. *, /, +, -, ^, sqrt(), pi) instead of LaTeX backslash commands (do NOT write \\frac, \\times, \\sqrt, etc.) so the JSON parses cleanly.

OUTPUT FORMAT:
Respond with ONLY valid raw JSON — no markdown, no commentary, no code fences:
{{
  "topic": "Specific {subj} Topic Title",
  "explanation": "100-140 word explanation of this {subj} concept...",
  "questions": [
    {{
      "id": 1,
      "question": "Q1 (Easiest / Warmup {subj} problem)?",
      "options": ["Distractor 0", "Correct Answer 1", "Distractor 2", "Distractor 3"],
      "correct_index": 1,
      "explanation": "Why Correct Answer 1 is correct in {subj} context."
    }},
    {{
      "id": 2,
      "question": "Q2 (Moderate application {subj} problem)?",
      "options": ["Distractor 0", "Distractor 1", "Distractor 2", "Correct Answer 3"],
      "correct_index": 3,
      "explanation": "Why Correct Answer 3 is correct."
    }},
    {{
      "id": 3,
      "question": "Q3 (Harder problem-solving {subj} question)?",
      "options": ["Correct Answer 0", "Distractor 1", "Distractor 2", "Distractor 3"],
      "correct_index": 0,
      "explanation": "Why Correct Answer 0 is correct."
    }},
    {{
      "id": 4,
      "question": "Q4 (Hardest analysis / puzzle {subj} problem)?",
      "options": ["Distractor 0", "Distractor 1", "Correct Answer 2", "Distractor 3"],
      "correct_index": 2,
      "explanation": "Why Correct Answer 2 is correct."
    }}
  ]
}}"""


def fallback_learning_content(req: LearningRequest) -> dict:
    subj = req.subject.lower()
    b_name = (req.building_name or "").lower()
    target_str = f"{subj} {b_name}"

    lvl = req.student_level

    if "derivat" in target_str:
        if lvl <= 1:
            return {
                "topic": "Differential Calculus: Fundamentals & Rates of Change",
                "explanation": "Derivatives measure the instantaneous rate of change and the slope of a line at any moment. For constant functions like f(x) = 15, the derivative is always 0 because constants never change. For a linear motion function like s(t) = 8t + 3, the derivative s'(t) represents constant velocity. Geometrically, the derivative at any point is the slope of the tangent line touching the curve at that exact coordinate.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the derivative d/dx of the constant function f(x) = 15?",
                        "options": ["15", "0", "1", "15x"],
                        "correct_index": 1,
                        "explanation": "The derivative of any constant value is always 0."
                    },
                    {
                        "id": 2,
                        "question": "For a linear motion function s(t) = 8t + 3, what is the velocity derivative s'(t)?",
                        "options": ["8", "8t", "11", "3"],
                        "correct_index": 0,
                        "explanation": "The derivative of linear 8t + 3 with respect to t is 8."
                    },
                    {
                        "id": 3,
                        "question": "Geometrically, what does the derivative of a function at a single point represent?",
                        "options": ["The area under the curve", "The slope of the tangent line at that point", "The distance to the origin", "The maximum height of the graph"],
                        "correct_index": 1,
                        "explanation": "The derivative at a point equals the slope of the tangent line touching the curve at that point."
                    },
                    {
                        "id": 4,
                        "question": "Using the power rule d/dx[x^n] = n*x^(n-1), what is d/dx[x^2]?",
                        "options": ["x", "2x", "2x^2", "x^3 / 3"],
                        "correct_index": 1,
                        "explanation": "Multiply by exponent 2 and decrease power to 1, yielding 2x."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Differential Calculus: Power Rule & Tangent Slopes",
                "explanation": "Level 2 Derivation dives into multi-step polynomial differentiation and instantaneous rates of change. By combining the power rule d/dx[a*x^n] = a*n*x^(n-1) with the sum rule, we differentiate complex polynomials term-by-term. To find the exact slope of a curve at a specific point x = x0, we first compute the derivative function f'(x), and then substitute x0 into f'(x). We also introduce fundamental trigonometric derivatives like d/dx[sin(x)] = cos(x).",
                "questions": [
                    {
                        "id": 1,
                        "question": "Using the power rule with coefficients, what is the derivative d/dx[5x^3 - 4x^2 + 7]?",
                        "options": ["15x^2 - 8x", "15x^3 - 8x^2", "5x^2 - 4x", "15x^2 - 8x + 7"],
                        "correct_index": 0,
                        "explanation": "d/dx[5x^3] = 15x^2, d/dx[-4x^2] = -8x, and d/dx[7] = 0, giving 15x^2 - 8x."
                    },
                    {
                        "id": 2,
                        "question": "What is the numerical slope of the curve y = 2x^2 + 3x - 1 at the specific point x = 3?",
                        "options": ["12", "15", "18", "21"],
                        "correct_index": 1,
                        "explanation": "The derivative is y' = 4x + 3. Evaluating at x = 3 gives y'(3) = 4(3) + 3 = 15."
                    },
                    {
                        "id": 3,
                        "question": "A particle moves with position s(t) = 4t^3 - 6t^2 + 20 meters. What is its instantaneous velocity v(t) = s'(t) at t = 2 seconds?",
                        "options": ["16 m/s", "24 m/s", "36 m/s", "48 m/s"],
                        "correct_index": 1,
                        "explanation": "Velocity v(t) = s'(t) = 12t^2 - 12t. At t = 2: 12(4) - 12(2) = 48 - 24 = 24 m/s."
                    },
                    {
                        "id": 4,
                        "question": "What is the derivative of the trigonometric expression f(x) = 3*sin(x) - 4*cos(x)?",
                        "options": ["3*cos(x) - 4*sin(x)", "3*cos(x) + 4*sin(x)", "-3*cos(x) - 4*sin(x)", "3*sin(x) + 4*cos(x)"],
                        "correct_index": 1,
                        "explanation": "d/dx[3*sin(x)] = 3*cos(x) and d/dx[-4*cos(x)] = -4*(-sin(x)) = +4*sin(x)."
                    }
                ]
            }
        else:
            return {
                "topic": "Differential Calculus: Product, Chain Rules & Critical Points",
                "explanation": "Advanced calculus analyzes composite and multiplied functions using the product rule (u*v)' = u'*v + u*v' and the chain rule d/dx[f(g(x))] = f'(g(x))*g'(x). Critical points occur where the derivative f'(x) equals 0 or is undefined, identifying local maxima, minima, and optimization points on functional curves.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Using the chain rule, what is the derivative of f(x) = (3x - 2)^4?",
                        "options": ["4(3x - 2)^3", "12(3x - 2)^3", "12(3x - 2)^4", "3(3x - 2)^3"],
                        "correct_index": 1,
                        "explanation": "Outer derivative 4(3x-2)^3 multiplied by inner derivative 3 gives 12(3x-2)^3."
                    },
                    {
                        "id": 2,
                        "question": "Using the product rule, evaluate d/dx[x^2 * cos(x)].",
                        "options": ["2x*cos(x) - x^2*sin(x)", "2x*cos(x) + x^2*sin(x)", "-2x*sin(x)", "x^2*cos(x) - 2x*sin(x)"],
                        "correct_index": 0,
                        "explanation": "d/dx[x^2]*cos(x) + x^2*d/dx[cos(x)] = 2x*cos(x) - x^2*sin(x)."
                    },
                    {
                        "id": 3,
                        "question": "Find the critical points (where f'(x) = 0) of the function f(x) = 2x^3 - 6x + 5.",
                        "options": ["x = 1 and x = -1", "x = 0 and x = 3", "x = 2 and x = -2", "x = sqrt(3)"],
                        "correct_index": 0,
                        "explanation": "f'(x) = 6x^2 - 6 = 0 => 6(x^2 - 1) = 0 => x = 1, -1."
                    },
                    {
                        "id": 4,
                        "question": "Using the quotient rule, find the derivative of y = x / (x + 1).",
                        "options": ["1 / (x + 1)^2", "-1 / (x + 1)^2", "1 / (x + 1)", "(2x + 1) / (x + 1)^2"],
                        "correct_index": 0,
                        "explanation": "[(1)(x+1) - (x)(1)] / (x+1)^2 = (x + 1 - x) / (x+1)^2 = 1 / (x+1)^2."
                    }
                ]
            }
    elif "integrat" in target_str:
        if lvl <= 1:
            return {
                "topic": "Integral Calculus: Fundamentals & Accumulation",
                "explanation": "Integration accumulates continuous quantities to calculate total displacement and the exact area under curves. By the reverse power rule, the integral of a constant k with respect to x is kx + C, where C is the arbitrary constant of integration. Integrating velocity over time gives total distance traveled.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the indefinite integral of the constant function f(x) = 4 with respect to x?",
                        "options": ["4x + C", "0", "4 + C", "x^4 + C"],
                        "correct_index": 0,
                        "explanation": "The antiderivative of any constant k is kx + C."
                    },
                    {
                        "id": 2,
                        "question": "Using the reverse power rule, evaluate the indefinite integral: integral of 3x^2 dx.",
                        "options": ["6x + C", "x^3 + C", "3x^3 + C", "x^2 + C"],
                        "correct_index": 1,
                        "explanation": "integral(3x^2 dx) = 3 * (x^3 / 3) + C = x^3 + C."
                    },
                    {
                        "id": 3,
                        "question": "What is the antiderivative of cos(x)?",
                        "options": ["-sin(x) + C", "sin(x) + C", "-cos(x) + C", "tan(x) + C"],
                        "correct_index": 1,
                        "explanation": "Since d/dx[sin(x)] = cos(x), the integral of cos(x) is sin(x) + C."
                    },
                    {
                        "id": 4,
                        "question": "Evaluate the definite integral from x = 0 to x = 2 of the function 2x dx.",
                        "options": ["2", "4", "6", "8"],
                        "correct_index": 1,
                        "explanation": "Antiderivative is x^2. Evaluating at 2 and 0 gives 2^2 - 0^2 = 4."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Integral Calculus: Reverse Power Rule & Definite Areas",
                "explanation": "Level 2 Integration tackles multi-term polynomial integration and computing bounded area under curves via definite integrals. We integrate polynomial expressions term by term using the reverse power rule integral(a*x^n dx) = a * (x^(n+1)/(n+1)) + C. The Fundamental Theorem of Calculus allows us to evaluate definite integrals F(b) - F(a) without needing the constant C.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Using the reverse power rule with coefficients, evaluate: integral of (6x^2 - 8x + 5) dx.",
                        "options": ["2x^3 - 4x^2 + 5x + C", "3x^3 - 8x^2 + 5x + C", "12x - 8 + C", "2x^3 - 8x^2 + C"],
                        "correct_index": 0,
                        "explanation": "6(x^3/3) - 8(x^2/2) + 5x + C = 2x^3 - 4x^2 + 5x + C."
                    },
                    {
                        "id": 2,
                        "question": "Evaluate the definite integral from x = 1 to x = 3 of (3x^2) dx.",
                        "options": ["24", "26", "27", "18"],
                        "correct_index": 1,
                        "explanation": "Antiderivative is x^3. Evaluating at 3 and 1: 3^3 - 1^3 = 27 - 1 = 26."
                    },
                    {
                        "id": 3,
                        "question": "What is the indefinite integral of f(x) = 4*cos(x) + 2*sin(x) dx?",
                        "options": ["4*sin(x) - 2*cos(x) + C", "-4*sin(x) + 2*cos(x) + C", "4*sin(x) + 2*cos(x) + C", "4*cos(x) - 2*sin(x) + C"],
                        "correct_index": 0,
                        "explanation": "integral(cos x dx) = sin x, and integral(sin x dx) = -cos x, giving 4*sin(x) - 2*cos(x) + C."
                    },
                    {
                        "id": 4,
                        "question": "What is the exact area bounded by the line y = 2x + 1, the x-axis, from x = 0 to x = 4?",
                        "options": ["16", "20", "24", "18"],
                        "correct_index": 1,
                        "explanation": "integral from 0 to 4 of (2x + 1) dx = [x^2 + x] from 0 to 4 = (16 + 4) - 0 = 20."
                    }
                ]
            }
        else:
            return {
                "topic": "Integral Calculus: Substitution & Integration by Parts",
                "explanation": "Advanced integration resolves complex products and composite functions using u-substitution (variable change) and integration by parts (integral u dv = uv - integral v du). These techniques enable solving areas between intersecting curves and computing physical centers of mass.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Using u-substitution with u = x^2 + 1, evaluate: integral of 2x * (x^2 + 1)^3 dx.",
                        "options": ["(x^2 + 1)^4 / 4 + C", "(x^2 + 1)^4 + C", "2(x^2 + 1)^4 + C", "(x^2 + 1)^3 / 3 + C"],
                        "correct_index": 0,
                        "explanation": "du = 2x dx, so integral(u^3 du) = u^4 / 4 + C = (x^2 + 1)^4 / 4 + C."
                    },
                    {
                        "id": 2,
                        "question": "Using integration by parts, evaluate: integral of x * e^x dx.",
                        "options": ["x*e^x - e^x + C", "x*e^x + e^x + C", "e^x + C", "x^2 * e^x / 2 + C"],
                        "correct_index": 0,
                        "explanation": "u = x, dv = e^x dx => du = dx, v = e^x. uv - integral(v du) = x*e^x - e^x + C."
                    },
                    {
                        "id": 3,
                        "question": "What is the total area bounded between the two curves y = 4 and y = x^2?",
                        "options": ["16/3", "32/3", "8", "64/3"],
                        "correct_index": 1,
                        "explanation": "Intersection at x = -2, 2. integral from -2 to 2 of (4 - x^2) dx = 2 * [4(2) - 8/3] = 2 * (16/3) = 32/3."
                    },
                    {
                        "id": 4,
                        "question": "Evaluate the definite integral from 0 to pi of sin(x) dx.",
                        "options": ["0", "1", "2", "-1"],
                        "correct_index": 2,
                        "explanation": "[-cos(x)] from 0 to pi = -cos(pi) - (-cos(0)) = -(-1) - (-1) = 1 + 1 = 2."
                    }
                ]
            }
    elif "trig" in target_str:
        if lvl <= 1:
            return {
                "topic": "Trigonometric Ratios & Right Triangles",
                "explanation": "Trigonometry explores the relationships between triangle side lengths and angles. For any acute angle in a right triangle, sine is opposite over hypotenuse, cosine is adjacent over hypotenuse, and tangent is opposite over adjacent (SOH-CAH-TOA). The Pythagorean theorem relates the sides via a^2 + b^2 = c^2.",
                "questions": [
                    {
                        "id": 1,
                        "question": "In a right triangle, which trigonometric ratio is defined as Opposite / Hypotenuse?",
                        "options": ["Cosine", "Sine", "Tangent", "Secant"],
                        "correct_index": 1,
                        "explanation": "By SOH-CAH-TOA, Sine = Opposite / Hypotenuse."
                    },
                    {
                        "id": 2,
                        "question": "In a right triangle with opposite side = 3 and adjacent side = 4, what is tan(theta)?",
                        "options": ["3/5", "4/5", "3/4", "4/3"],
                        "correct_index": 2,
                        "explanation": "Tangent = Opposite / Adjacent = 3/4."
                    },
                    {
                        "id": 3,
                        "question": "In a right triangle with legs of length 3 and 4, what is the length of the hypotenuse?",
                        "options": ["5", "6", "7", "25"],
                        "correct_index": 0,
                        "explanation": "sqrt(3^2 + 4^2) = sqrt(9 + 16) = sqrt(25) = 5."
                    },
                    {
                        "id": 4,
                        "question": "What is the exact value of sin(90 degrees) or sin(pi/2 radians)?",
                        "options": ["0", "1", "0.5", "undefined"],
                        "correct_index": 1,
                        "explanation": "At 90 degrees on the unit circle, the y-coordinate is 1."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Trigonometry: Standard Angles, Radians & Pythagorean Identities",
                "explanation": "Level 2 Trigonometry focuses on unit circle coordinates, converting angles to radians (pi = 180 degrees), standard angle exact values (30, 45, 60 degrees), and the fundamental identity sin^2(theta) + cos^2(theta) = 1. These mathematical relationships enable calculating exact side lengths without a calculator.",
                "questions": [
                    {
                        "id": 1,
                        "question": "In a right triangle where angle theta = 30 degrees and the hypotenuse is 12, what is the length of the opposite side?",
                        "options": ["6", "6*sqrt(3)", "8", "4"],
                        "correct_index": 0,
                        "explanation": "sin(30 deg) = 1/2. Opposite = 12 * sin(30) = 12 * 1/2 = 6."
                    },
                    {
                        "id": 2,
                        "question": "What is the exact value of cos(60 degrees)?",
                        "options": ["0.5", "sqrt(3)/2", "sqrt(2)/2", "1"],
                        "correct_index": 0,
                        "explanation": "cos(60 degrees) = 1/2 = 0.5."
                    },
                    {
                        "id": 3,
                        "question": "Convert an angle of 150 degrees into radians in terms of pi.",
                        "options": ["5pi / 6", "3pi / 4", "2pi / 3", "7pi / 6"],
                        "correct_index": 0,
                        "explanation": "150 * (pi / 180) = 15/18 pi = 5pi / 6 radians."
                    },
                    {
                        "id": 4,
                        "question": "If sin(theta) = 3/5 for an acute angle theta, use sin^2(theta) + cos^2(theta) = 1 to find cos(theta).",
                        "options": ["4/5", "3/4", "5/4", "2/5"],
                        "correct_index": 0,
                        "explanation": "cos^2(theta) = 1 - (3/5)^2 = 1 - 9/25 = 16/25 => cos(theta) = 4/5."
                    }
                ]
            }
        else:
            return {
                "topic": "Advanced Trigonometry: Laws of Sines/Cosines & Identities",
                "explanation": "Advanced trigonometry analyzes arbitrary non-right triangles using the Law of Sines and the Law of Cosines (c^2 = a^2 + b^2 - 2ab*cos(C)), double-angle formulas like sin(2A) = 2*sin(A)*cos(A), and reciprocal functions (sec, csc, cot).",
                "questions": [
                    {
                        "id": 1,
                        "question": "Given sin(A) = 3/5 and cos(A) = 4/5, what is the value of sin(2A) using the double angle identity?",
                        "options": ["24/25", "7/25", "12/25", "6/5"],
                        "correct_index": 0,
                        "explanation": "sin(2A) = 2 * sin(A) * cos(A) = 2 * (3/5) * (4/5) = 24/25."
                    },
                    {
                        "id": 2,
                        "question": "In a triangle with sides a = 5, b = 7, and angle C = 60 degrees, what is c^2 by the Law of Cosines?",
                        "options": ["39", "49", "74", "35"],
                        "correct_index": 0,
                        "explanation": "c^2 = 5^2 + 7^2 - 2(5)(7)*cos(60) = 25 + 49 - 70(0.5) = 74 - 35 = 39."
                    },
                    {
                        "id": 3,
                        "question": "Which reciprocal trigonometric function is defined as 1 / cos(theta)?",
                        "options": ["Secant (sec)", "Cosecant (csc)", "Cotangent (cot)", "Tangent (tan)"],
                        "correct_index": 0,
                        "explanation": "sec(theta) = 1 / cos(theta) by definition."
                    },
                    {
                        "id": 4,
                        "question": "Solve for theta in the interval [0, 2pi) such that 2*sin(theta) - 1 = 0.",
                        "options": ["pi/6 and 5pi/6", "pi/3 and 2pi/3", "pi/4 and 3pi/4", "pi/2 only"],
                        "correct_index": 0,
                        "explanation": "sin(theta) = 1/2. In [0, 2pi), sin is 1/2 at theta = pi/6 and theta = 5pi/6."
                    }
                ]
            }
    elif "algebra" in target_str:
        if lvl <= 1:
            return {
                "topic": "Algebra: 1-Step Equations & Expressions",
                "explanation": "Algebra uses letters to represent unknown numbers. Solving an equation means finding values that balance the scale. In 1-step equations, we perform inverse operations: subtracting a number to undo addition, or dividing to undo multiplication.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Solve for x in the 1-step linear equation: x + 9 = 23.",
                        "options": ["x = 14", "x = 12", "x = 32", "x = 16"],
                        "correct_index": 0,
                        "explanation": "Subtract 9 from both sides: x = 23 - 9 = 14."
                    },
                    {
                        "id": 2,
                        "question": "Solve for x in the equation: 5x = 45.",
                        "options": ["x = 9", "x = 8", "x = 40", "x = 7"],
                        "correct_index": 0,
                        "explanation": "Divide both sides by 5: x = 45 / 5 = 9."
                    },
                    {
                        "id": 3,
                        "question": "Simplify the algebraic expression by combining like terms: 4x + 7x - 3x.",
                        "options": ["8x", "11x", "8", "14x"],
                        "correct_index": 0,
                        "explanation": "(4 + 7 - 3)x = 8x."
                    },
                    {
                        "id": 4,
                        "question": "If a = 4 and b = 3, evaluate the expression 2a + 3b.",
                        "options": ["17", "14", "24", "11"],
                        "correct_index": 0,
                        "explanation": "2(4) + 3(3) = 8 + 9 = 17."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Algebra: 2-Step Equations & Quadratic Factoring",
                "explanation": "Level 2 Algebra introduces multi-step equations with variables on both sides, factoring quadratic trinomials into binomials, and slope-intercept linear equations (y = mx + b). These core skills form the backbone of intermediate mathematical problem-solving.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Solve for x in the 2-step equation: 4x - 11 = 25.",
                        "options": ["x = 9", "x = 8", "x = 7", "x = 10"],
                        "correct_index": 0,
                        "explanation": "Add 11 to both sides: 4x = 36. Then divide by 4: x = 9."
                    },
                    {
                        "id": 2,
                        "question": "Solve the equation with variables on both sides: 7x - 5 = 3x + 19.",
                        "options": ["x = 6", "x = 5", "x = 4", "x = 7"],
                        "correct_index": 0,
                        "explanation": "Subtract 3x: 4x - 5 = 19. Add 5: 4x = 24. Divide by 4: x = 6."
                    },
                    {
                        "id": 3,
                        "question": "Factor the quadratic trinomial into two binomials: x^2 - 7x + 10.",
                        "options": ["(x - 2)(x - 5)", "(x + 2)(x + 5)", "(x - 1)(x - 10)", "(x + 1)(x - 10)"],
                        "correct_index": 0,
                        "explanation": "-2 and -5 multiply to 10 and add to -7."
                    },
                    {
                        "id": 4,
                        "question": "What is the slope (m) and y-intercept (b) of the linear equation 3x + 2y = 12?",
                        "options": ["m = -3/2, b = 6", "m = 3/2, b = 12", "m = -3, b = 6", "m = 2, b = 4"],
                        "correct_index": 0,
                        "explanation": "2y = -3x + 12 => y = (-3/2)x + 6. Slope is -3/2, y-intercept is 6."
                    }
                ]
            }
        else:
            return {
                "topic": "Advanced Algebra: Systems & Quadratic Formula",
                "explanation": "Advanced algebra covers systems of simultaneous equations, the quadratic formula x = (-b +- sqrt(b^2 - 4ac)) / (2a), the discriminant, and rational exponents.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Solve the linear system: 2x + y = 11 and x - y = 1.",
                        "options": ["x = 4, y = 3", "x = 5, y = 1", "x = 3, y = 5", "x = 6, y = -1"],
                        "correct_index": 0,
                        "explanation": "Add equations: 3x = 12 => x = 4, then y = 4 - 1 = 3."
                    },
                    {
                        "id": 2,
                        "question": "What is the discriminant of 2x^2 - 4x + 5 = 0, and what does it indicate?",
                        "options": ["-24, indicating two complex conjugate roots", "24, indicating two distinct real roots", "0, indicating one repeated root", "-16, indicating complex roots"],
                        "correct_index": 0,
                        "explanation": "b^2 - 4ac = (-4)^2 - 4(2)(5) = 16 - 40 = -24 (negative means complex roots)."
                    },
                    {
                        "id": 3,
                        "question": "Find the roots of the quadratic equation 2x^2 + 5x - 3 = 0 using factoring or the quadratic formula.",
                        "options": ["x = 0.5 and x = -3", "x = -0.5 and x = 3", "x = 1 and x = -3", "x = 2 and x = -1"],
                        "correct_index": 0,
                        "explanation": "(2x - 1)(x + 3) = 0 => x = 1/2 = 0.5 or x = -3."
                    },
                    {
                        "id": 4,
                        "question": "Simplify the exponential expression: (2x^3 * y^2)^3 / (4x^4 * y).",
                        "options": ["2x^5 * y^5", "2x^4 * y^5", "4x^5 * y^6", "8x^5 * y^5"],
                        "correct_index": 0,
                        "explanation": "[8x^9 * y^6] / [4x^4 * y] = (8/4) * x^(9-4) * y^(6-1) = 2x^5 * y^5."
                    }
                ]
            }
    elif "geometry" in target_str:
        if lvl <= 1:
            return {
                "topic": "Geometry: 2D Shapes, Angles & Perimeter",
                "explanation": "Geometry investigates the properties and measurements of shapes, angles, and lines. In Euclidean geometry, the interior angles of any triangle always add up to 180 degrees. Perimeter measures the boundary length around a figure, while area measures the surface inside.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the perimeter of a rectangle with length 7 cm and width 4 cm?",
                        "options": ["22 cm", "28 cm", "11 cm", "18 cm"],
                        "correct_index": 0,
                        "explanation": "Perimeter = 2 * (length + width) = 2 * (7 + 4) = 2 * 11 = 22 cm."
                    },
                    {
                        "id": 2,
                        "question": "What is the area of a square with side length 6 meters?",
                        "options": ["36 m^2", "24 m^2", "12 m^2", "30 m^2"],
                        "correct_index": 0,
                        "explanation": "Area = side * side = 6 * 6 = 36 m^2."
                    },
                    {
                        "id": 3,
                        "question": "What is the sum of interior angles in any two-dimensional triangle?",
                        "options": ["180 degrees", "90 degrees", "270 degrees", "360 degrees"],
                        "correct_index": 0,
                        "explanation": "The interior angles of any triangle in Euclidean space always sum to 180 degrees."
                    },
                    {
                        "id": 4,
                        "question": "How many degrees are in a perfect right angle?",
                        "options": ["90 degrees", "45 degrees", "180 degrees", "60 degrees"],
                        "correct_index": 0,
                        "explanation": "A right angle is exactly 90 degrees."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Geometry: Circles, Coordinates & Pythagorean Theorem",
                "explanation": "Level 2 Geometry advances into circle formulas (circumference = 2*pi*r, area = pi*r^2), the 2D coordinate distance formula d = sqrt((x2-x1)^2 + (y2-y1)^2), and transversal angle relationships on parallel lines.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the area of a circle with radius r = 7 cm (using pi = 22/7)?",
                        "options": ["154 cm^2", "44 cm^2", "88 cm^2", "196 cm^2"],
                        "correct_index": 0,
                        "explanation": "Area = pi * r^2 = (22/7) * 7 * 7 = 22 * 7 = 154 cm^2."
                    },
                    {
                        "id": 2,
                        "question": "What is the area of a triangle with base 14 cm and perpendicular height 9 cm?",
                        "options": ["63 cm^2", "126 cm^2", "46 cm^2", "54 cm^2"],
                        "correct_index": 0,
                        "explanation": "Area = 1/2 * base * height = 1/2 * 14 * 9 = 7 * 9 = 63 cm^2."
                    },
                    {
                        "id": 3,
                        "question": "Find the distance between the two points A(1, 2) and B(5, 5) on the Cartesian coordinate plane.",
                        "options": ["5", "7", "4", "sqrt(17)"],
                        "correct_index": 0,
                        "explanation": "d = sqrt((5-1)^2 + (5-2)^2) = sqrt(4^2 + 3^2) = sqrt(16 + 9) = sqrt(25) = 5."
                    },
                    {
                        "id": 4,
                        "question": "Two parallel lines are intersected by a transversal. If one interior angle is 65 degrees, what is the alternate interior angle?",
                        "options": ["65 degrees", "115 degrees", "90 degrees", "25 degrees"],
                        "correct_index": 0,
                        "explanation": "Alternate interior angles created by parallel lines and a transversal are equal: 65 degrees."
                    }
                ]
            }
        else:
            return {
                "topic": "Advanced Geometry: 3D Solids, Vectors & Circle Equations",
                "explanation": "Advanced geometry explores 3D volume and surface area, 2D/3D vector magnitudes, and standard coordinate equations of circles (x-h)^2 + (y-k)^2 = r^2.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the volume of a cylinder with radius 3 cm and height 10 cm in terms of pi?",
                        "options": ["90*pi cm^3", "60*pi cm^3", "30*pi cm^3", "100*pi cm^3"],
                        "correct_index": 0,
                        "explanation": "Volume = pi * r^2 * h = pi * (3^2) * 10 = 90*pi cm^3."
                    },
                    {
                        "id": 2,
                        "question": "What is the length of the 3D space diagonal of a box with dimensions 3 x 4 x 12?",
                        "options": ["13", "15", "17", "12"],
                        "correct_index": 0,
                        "explanation": "Diagonal = sqrt(3^2 + 4^2 + 12^2) = sqrt(9 + 16 + 144) = sqrt(169) = 13."
                    },
                    {
                        "id": 3,
                        "question": "What is the center and radius of the circle defined by (x - 4)^2 + (y + 2)^2 = 49?",
                        "options": ["Center (4, -2), radius 7", "Center (-4, 2), radius 7", "Center (4, -2), radius 49", "Center (-4, 2), radius 49"],
                        "correct_index": 0,
                        "explanation": "Standard form (x-h)^2 + (y-k)^2 = r^2 yields center (4, -2) and radius sqrt(49) = 7."
                    },
                    {
                        "id": 4,
                        "question": "What is the magnitude of the 2D vector v = [5, 12]?",
                        "options": ["13", "17", "7", "25"],
                        "correct_index": 0,
                        "explanation": "Magnitude = sqrt(5^2 + 12^2) = sqrt(25 + 144) = sqrt(169) = 13."
                    }
                ]
            }
    elif "arithmetic" in target_str or "number" in target_str:
        if lvl <= 1:
            return {
                "topic": "Arithmetic: Mental Math & Multiplication Tables",
                "explanation": "Arithmetic is the fundamental branch of math dealing with addition, subtraction, multiplication, and division. Mastering multiplication tables 1 through 12 and recognizing even and odd number patterns creates the foundation for all quantitative reasoning.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is 7 * 8?",
                        "options": ["56", "54", "48", "64"],
                        "correct_index": 0,
                        "explanation": "7 * 8 = 56, a fundamental times-table fact."
                    },
                    {
                        "id": 2,
                        "question": "What is 144 / 12?",
                        "options": ["12", "11", "13", "14"],
                        "correct_index": 0,
                        "explanation": "144 divided by 12 equals 12."
                    },
                    {
                        "id": 3,
                        "question": "Which of the following numbers is an even number?",
                        "options": ["28", "35", "19", "47"],
                        "correct_index": 0,
                        "explanation": "28 ends in 8 and is evenly divisible by 2."
                    },
                    {
                        "id": 4,
                        "question": "What is 45 + 78?",
                        "options": ["123", "113", "133", "125"],
                        "correct_index": 0,
                        "explanation": "45 + 78 = 123."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Arithmetic: Order of Operations, GCF/LCM & Unlike Fractions",
                "explanation": "Level 2 Arithmetic challenges you with multi-step calculations using the proper order of operations (PEMDAS/BODMAS: Parentheses, Exponents, Multiplication & Division left-to-right, Addition & Subtraction left-to-right), finding the Greatest Common Factor (GCF) and Least Common Multiple (LCM), and adding fractions with unlike denominators.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Evaluate using the proper order of operations (PEMDAS): 18 - 3 * (4 + 2) / 2.",
                        "options": ["9", "45", "12", "15"],
                        "correct_index": 0,
                        "explanation": "Brackets first: (4+2)=6. Then multiply and divide left to right: 3*6=18, 18/2=9. Finally subtract: 18 - 9 = 9."
                    },
                    {
                        "id": 2,
                        "question": "What is the Greatest Common Factor (GCF) of 48 and 72?",
                        "options": ["24", "12", "16", "8"],
                        "correct_index": 0,
                        "explanation": "24 is the largest integer dividing both 48 (24*2) and 72 (24*3)."
                    },
                    {
                        "id": 3,
                        "question": "Add the two fractions with unlike denominators: 2/3 + 3/4.",
                        "options": ["17/12", "5/7", "11/12", "5/12"],
                        "correct_index": 0,
                        "explanation": "Common denominator is 12: 8/12 + 9/12 = 17/12 (or 1 and 5/12)."
                    },
                    {
                        "id": 4,
                        "question": "What is the prime factorization of 360?",
                        "options": ["2^3 * 3^2 * 5", "2^2 * 3^3 * 5", "2^4 * 3 * 5", "2^3 * 3 * 15"],
                        "correct_index": 0,
                        "explanation": "360 = 8 * 9 * 5 = 2^3 * 3^2 * 5."
                    }
                ]
            }
        else:
            return {
                "topic": "Advanced Arithmetic: Exponent Laws, Roots & Scientific Notation",
                "explanation": "Advanced arithmetic covers powers and exponent rules, square and cube roots, Least Common Multiples (LCM), percentages, and scientific notation.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Evaluate the expression: 2^5 * 2^(-2) + 3^3.",
                        "options": ["35", "19", "43", "27"],
                        "correct_index": 0,
                        "explanation": "2^(5-2) + 27 = 2^3 + 27 = 8 + 27 = 35."
                    },
                    {
                        "id": 2,
                        "question": "What is the Least Common Multiple (LCM) of 12, 18, and 30?",
                        "options": ["180", "90", "360", "60"],
                        "correct_index": 0,
                        "explanation": "12 = 2^2 * 3, 18 = 2 * 3^2, 30 = 2 * 3 * 5. LCM = 2^2 * 3^2 * 5 = 4 * 9 * 5 = 180."
                    },
                    {
                        "id": 3,
                        "question": "If 35% of a number is 140, what is 60% of that same number?",
                        "options": ["240", "210", "280", "200"],
                        "correct_index": 0,
                        "explanation": "Number is 140 / 0.35 = 400. 60% of 400 = 0.60 * 400 = 240."
                    },
                    {
                        "id": 4,
                        "question": "Simplify in scientific notation: (4.0 * 10^5) * (3.0 * 10^3).",
                        "options": ["1.2 * 10^9", "12 * 10^8", "1.2 * 10^8", "7.0 * 10^8"],
                        "correct_index": 0,
                        "explanation": "12.0 * 10^8 = 1.2 * 10^9 in proper scientific notation."
                    }
                ]
            }
    elif "program" in subj or "code" in subj:
        if lvl <= 1:
            return {
                "topic": "Programming: Variables, Flow & Basic Logic",
                "explanation": "Programming is giving step-by-step instructions to a computer. Variables store data values in memory, print statements output text to the screen, and conditional if-else statements make decisions based on whether a condition is true or false.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the primary purpose of a variable in code?",
                        "options": ["To store data in memory for later use", "To print graphics on screen", "To increase Internet speed", "To encrypt user password"],
                        "correct_index": 0,
                        "explanation": "Variables hold values that can be referenced and modified throughout a program."
                    },
                    {
                        "id": 2,
                        "question": "Which construct allows a program to make decisions based on conditions?",
                        "options": ["If-Else Statements", "Variables", "Arrays", "Comments"],
                        "correct_index": 0,
                        "explanation": "If-else statements evaluate conditions and branch execution accordingly."
                    },
                    {
                        "id": 3,
                        "question": "What is the primary function of a loop in code?",
                        "options": ["To repeat a block of code multiple times", "To store a single number", "To style the visual layout", "To terminate the application"],
                        "correct_index": 0,
                        "explanation": "Loops allow repeated execution of code without duplication."
                    },
                    {
                        "id": 4,
                        "question": "What data type represents a binary True or False value?",
                        "options": ["Boolean", "Integer", "String", "Float"],
                        "correct_index": 0,
                        "explanation": "Booleans represent true or false values in computer science."
                    }
                ]
            }
        elif lvl == 2:
            return {
                "topic": "Programming: Loop Tracing, Arrays & Function Returns",
                "explanation": "Level 2 Programming requires tracing loop execution, understanding zero-indexed arrays, calculating remainders with the modulo operator (%), and tracking function return values across nested calls.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the output of this loop: count = 0; for i in range(1, 5): count += i?",
                        "options": ["10", "15", "5", "6"],
                        "correct_index": 0,
                        "explanation": "range(1, 5) iterates over 1, 2, 3, 4. The sum is 1 + 2 + 3 + 4 = 10."
                    },
                    {
                        "id": 2,
                        "question": "In a zero-indexed array arr = [10, 20, 30, 40, 50], what is the value of arr[3]?",
                        "options": ["40", "30", "50", "20"],
                        "correct_index": 0,
                        "explanation": "arr[0]=10, arr[1]=20, arr[2]=30, and arr[3]=40."
                    },
                    {
                        "id": 3,
                        "question": "What is the exact result of the modulo operation: 17 % 5?",
                        "options": ["2", "3", "3.4", "1"],
                        "correct_index": 0,
                        "explanation": "17 divided by 5 is 3 with a remainder of 2. % returns the remainder 2."
                    },
                    {
                        "id": 4,
                        "question": "Given def add(a, b): return a + b, what is the value of add(add(2, 3), 4)?",
                        "options": ["9", "7", "5", "10"],
                        "correct_index": 0,
                        "explanation": "Inner add(2, 3) returns 5. Outer add(5, 4) returns 9."
                    }
                ]
            }
        else:
            return {
                "topic": "Advanced Computer Science: Algorithms, Stacks & OOP",
                "explanation": "Advanced programming analyzes algorithm efficiency with Big-O notation, Last-In-First-Out (LIFO) stack structures, recursive base cases, and Object-Oriented polymorphism.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the worst-case time complexity of binary search on a sorted array of n elements?",
                        "options": ["O(log n)", "O(n)", "O(n^2)", "O(1)"],
                        "correct_index": 0,
                        "explanation": "Binary search halves the search space at each step, running in O(log n) time."
                    },
                    {
                        "id": 2,
                        "question": "Which data structure follows a Last-In, First-Out (LIFO) protocol?",
                        "options": ["Stack", "Queue", "Linked List", "Binary Heap"],
                        "correct_index": 0,
                        "explanation": "A Stack operates strictly as Last-In, First-Out."
                    },
                    {
                        "id": 3,
                        "question": "What happens if a recursive function does not define a proper base case?",
                        "options": ["It causes a stack overflow error", "It finishes instantly", "It compiles to a faster loop", "It returns null"],
                        "correct_index": 0,
                        "explanation": "Without a terminating base case, recursive calls consume all stack memory."
                    },
                    {
                        "id": 4,
                        "question": "In Object-Oriented Programming, when a child class provides a specific implementation of a parent method, what is this called?",
                        "options": ["Method Overriding (Polymorphism)", "Encapsulation", "Multiple Inheritance", "Static Casting"],
                        "correct_index": 0,
                        "explanation": "Method overriding allows a subclass to provide a specific implementation of an inherited method."
                    }
                ]
            }
    elif "physic" in subj or "space" in subj or "astronomy" in subj:
        return {
            "topic": "Gravity & Celestial Motions",
            "explanation": "Gravity is an invisible pulling force that pulls objects toward each other. The larger an object's mass, the stronger its gravitational pull! Earth keeps the Moon in orbit just like an invisible cosmic tether, while the Sun pulls all planets around it in predictable orbital paths.",
            "questions": [
                {
                    "id": 1,
                    "question": "What determines how strong gravitational attraction is between two bodies?",
                    "options": ["Their mass and distance", "Their color and light", "Their temperature and wind", "Their age"],
                    "correct_index": 0,
                    "explanation": "Gravity depends directly on mass and inversely on distance squared."
                },
                {
                    "id": 2,
                    "question": "Why do planets orbit the Sun rather than drifting into deep space?",
                    "options": ["Sun's solar winds push them", "Sun's immense gravitational pull holds them", "Magnetic force from Earth", "Starlight radiation pressure"],
                    "correct_index": 1,
                    "explanation": "The massive gravitational mass of the Sun keeps planets tethered in orbit."
                },
                {
                    "id": 3,
                    "question": "What happens to weight on the Moon compared to Earth?",
                    "options": ["Weight increases", "Weight decreases", "Weight stays exactly identical", "Weight becomes infinite"],
                    "correct_index": 1,
                    "explanation": "The Moon has less mass than Earth, so its gravitational pull is weaker."
                },
                {
                    "id": 4,
                    "question": "What shape are celestial orbits around a sun?",
                    "options": ["Perfect squares", "Ellipses", "Straight lines", "Triangles"],
                    "correct_index": 1,
                    "explanation": "Planetary orbits follow elliptical paths around their focus star."
                }
            ]
        }
    elif "chem" in subj or "potion" in subj or "alchemy" in subj:
        return {
            "topic": "Chemical Reactions & Potion States",
            "explanation": "Chemical reactions occur when molecules break old bonds and form new ones to create entirely new substances. Think of atomic building blocks rearranging into a whole new magical potion! Exothermic reactions release warmth, while endothermic reactions absorb heat from their surroundings.",
            "questions": [
                {
                    "id": 1,
                    "question": "What defines a chemical reaction?",
                    "options": ["Changing state without changing bonds", "Rearranging atoms to create new substances", "Cooling liquid into solid ice", "Dissolving sugar in warm water"],
                    "correct_index": 1,
                    "explanation": "Chemical reactions form new chemical bonds and new substances."
                },
                {
                    "id": 2,
                    "question": "What is an exothermic reaction?",
                    "options": ["A reaction that absorbs energy/heat", "A reaction that releases energy/heat", "A reaction with no energy change", "A reaction that only occurs in space"],
                    "correct_index": 1,
                    "explanation": "Exothermic reactions give off heat to their environment."
                },
                {
                    "id": 3,
                    "question": "What speeds up a chemical reaction without being consumed?",
                    "options": ["Catalyst", "Solvent", "Product", "Inhibitor"],
                    "correct_index": 0,
                    "explanation": "Catalysts lower activation energy to speed up reactions."
                },
                {
                    "id": 4,
                    "question": "What is the pH level of a neutral substance like pure water?",
                    "options": ["0", "7", "14", "3"],
                    "correct_index": 1,
                    "explanation": "A pH of 7 represents a neutral solution."
                }
            ]
        }
    elif "math" in subj:
        lvl = req.student_level
        # Level 1: Foundational Arithmetic & Times Tables
        if lvl <= 1:
            return {
                "topic": "Multiplication & Division Fundamentals",
                "explanation": "Multiplication is repeated addition: 3 * 4 means adding four 3s together to get 12. Division is the exact opposite: dividing 12 apples equally among 4 friends gives 3 apples each. Memorizing your 1 to 12 multiplication tables gives you the ultimate mental math superpower across all of mathematics!",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is 7 * 8?",
                        "options": ["56", "54", "48", "64"],
                        "correct_index": 0,
                        "explanation": "7 * 8 = 56, a fundamental times-table fact."
                    },
                    {
                        "id": 2,
                        "question": "Which operation is the inverse (opposite) of multiplication?",
                        "options": ["Division", "Addition", "Subtraction", "Squaring"],
                        "correct_index": 0,
                        "explanation": "Division undoes multiplication, just as subtraction undoes addition."
                    },
                    {
                        "id": 3,
                        "question": "If 36 / 6 = 6, which multiplication equation confirms this?",
                        "options": ["6 * 6 = 36", "6 + 6 = 12", "6 - 6 = 0", "36 * 1 = 36"],
                        "correct_index": 0,
                        "explanation": "6 * 6 = 36 directly verifies that 36 / 6 = 6."
                    },
                    {
                        "id": 4,
                        "question": "A wizard arranges 9 trays of 8 magic crystals each. How many crystals in total?",
                        "options": ["72", "64", "81", "17"],
                        "correct_index": 0,
                        "explanation": "9 groups of 8 = 9 * 8 = 72 crystals."
                    }
                ]
            }
        # Level 2: Order of Operations & Pre-Algebra (Significantly Harder than Level 1)
        elif lvl == 2:
            return {
                "topic": "Pre-Algebra & Order of Operations (Level 2)",
                "explanation": "Level 2 Mathematics advances beyond simple times tables to multi-step operations using PEMDAS/BODMAS, solving two-step algebraic equations, calculating percentages, and adding fractions with unlike denominators.",
                "questions": [
                    {
                        "id": 1,
                        "question": "Evaluate using the order of operations (PEMDAS): 14 + 6 * (8 - 5) / 2.",
                        "options": ["23", "30", "19", "25"],
                        "correct_index": 0,
                        "explanation": "(8-5)=3. Then 6*3=18. Then 18/2=9. Finally 14+9 = 23."
                    },
                    {
                        "id": 2,
                        "question": "Solve for x in the two-step equation: 3x + 7 = 25.",
                        "options": ["x = 6", "x = 5", "x = 8", "x = 4"],
                        "correct_index": 0,
                        "explanation": "Subtract 7: 3x = 18. Divide by 3: x = 6."
                    },
                    {
                        "id": 3,
                        "question": "What is 2/5 + 1/3 as a single fraction?",
                        "options": ["11/15", "3/8", "3/15", "7/15"],
                        "correct_index": 0,
                        "explanation": "Common denominator is 15: 6/15 + 5/15 = 11/15."
                    },
                    {
                        "id": 4,
                        "question": "A merchant discounts a 60 coin spell book by 25%. What is the new price?",
                        "options": ["45 coins", "50 coins", "40 coins", "48 coins"],
                        "correct_index": 0,
                        "explanation": "25% of 60 is 15. The discounted price is 60 - 15 = 45 coins."
                    }
                ]
            }
        # Level 3-4: Pre-Algebra & Ratios (Easy -> Harder)
        elif lvl <= 4:
            return {
                "topic": "Ratios & Solving for Unknowns",
                "explanation": "A ratio compares two quantities, such as 2 parts red paint to 3 parts blue paint (2:3). A proportion states two ratios are equal: a/b = c/d. To solve for an unknown variable x, cross-multiply: a × d = b × c. Proportions allow you to scale recipes, read maps, and calculate speeds with precision.",
                "questions": [
                    {
                        "id": 1,
                        "question": "If a map uses a scale of 1 cm : 5 km, what real-world distance does 4 cm represent?",
                        "options": ["9 km", "20 km", "4 km", "5 km"],
                        "correct_index": 1,
                        "explanation": "4 cm × 5 km/cm = 20 km."
                    },
                    {
                        "id": 2,
                        "question": "Solve for x in the linear equation: 2x + 6 = 14",
                        "options": ["x = 3", "x = 4", "x = 5", "x = 2"],
                        "correct_index": 1,
                        "explanation": "Subtract 6 from both sides: 2x = 8, then divide by 2: x = 4."
                    },
                    {
                        "id": 3,
                        "question": "Solve the proportion for x: 3 / 5 = x / 20",
                        "options": ["x = 10", "x = 12", "x = 15", "x = 9"],
                        "correct_index": 1,
                        "explanation": "Cross-multiply: 5x = 60, therefore x = 12."
                    },
                    {
                        "id": 4,
                        "question": "A vehicle travels 150 km in 3 hours. At the same speed, how far will it travel in 5 hours?",
                        "options": ["200 km", "250 km", "300 km", "180 km"],
                        "correct_index": 1,
                        "explanation": "Speed = 150 / 3 = 50 km/h. Distance in 5 hours = 50 × 5 = 250 km."
                    }
                ]
            }
        # Level 5-6: Intermediate Algebra & Geometry (Easy -> Harder)
        elif lvl <= 6:
            return {
                "topic": "Quadratic Equations & Discriminants",
                "explanation": "A quadratic equation has the standard form ax² + bx + c = 0. Its solutions are given by the quadratic formula: x = (−b ± √(b² − 4ac)) / (2a). The term b² − 4ac is called the discriminant: if positive, there are 2 distinct real roots; if zero, exactly 1 repeated real root; if negative, 2 complex roots.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the maximum number of real roots a quadratic equation can have?",
                        "options": ["1", "2", "3", "Infinite"],
                        "correct_index": 1,
                        "explanation": "By the Fundamental Theorem of Algebra, a degree-2 polynomial has at most 2 roots."
                    },
                    {
                        "id": 2,
                        "question": "What does the discriminant value (b² − 4ac = 0) indicate about the roots?",
                        "options": ["Two distinct real roots", "Exactly one repeated real root", "No real roots", "Infinite solutions"],
                        "correct_index": 1,
                        "explanation": "When b² − 4ac = 0, the parabola touches the x-axis at exactly one point (a double root)."
                    },
                    {
                        "id": 3,
                        "question": "Solve x² − 5x + 6 = 0 by factoring. What are the roots?",
                        "options": ["x = 2 and x = 3", "x = −2 and x = −3", "x = 1 and x = 6", "x = 5 and x = 1"],
                        "correct_index": 0,
                        "explanation": "x² − 5x + 6 factors into (x − 2)(x − 3) = 0, so x = 2 or x = 3."
                    },
                    {
                        "id": 4,
                        "question": "In a right triangle with legs of length 6 and 8, what is the length of the hypotenuse?",
                        "options": ["10", "12", "14", "9"],
                        "correct_index": 0,
                        "explanation": "By Pythagorean theorem: c = √(6² + 8²) = √(36 + 64) = √100 = 10."
                    }
                ]
            }
        # Level 7-8: Advanced Sequences, Trigonometry & Vectors (Easy -> Harder)
        elif lvl <= 8:
            return {
                "topic": "Geometric Series & Convergence",
                "explanation": "A geometric sequence multiplies each term by a constant ratio r: a, ar, ar², ar³... The sum of the first n terms is Sₙ = a(1 − rⁿ)/(1 − r). If |r| < 1, the infinite sum converges to a finite value S = a / (1 − r). This principle governs compound interest formulas, fractal dimension calculations, and digital signal processing.",
                "questions": [
                    {
                        "id": 1,
                        "question": "In the sequence 3, 12, 48, 192..., what is the common ratio r?",
                        "options": ["3", "4", "6", "9"],
                        "correct_index": 1,
                        "explanation": "12 / 3 = 4, 48 / 12 = 4, so the common ratio r is 4."
                    },
                    {
                        "id": 2,
                        "question": "What is the 5th term of a geometric sequence where a₁ = 2 and r = 3?",
                        "options": ["54", "162", "486", "18"],
                        "correct_index": 1,
                        "explanation": "a₅ = a₁ × r⁴ = 2 × 3⁴ = 2 × 81 = 162."
                    },
                    {
                        "id": 3,
                        "question": "Under what condition does an infinite geometric series a + ar + ar² + ... converge?",
                        "options": ["|r| > 1", "|r| < 1", "r = 1", "r = 0 only"],
                        "correct_index": 1,
                        "explanation": "An infinite geometric series converges to a/(1−r) if and only if |r| < 1."
                    },
                    {
                        "id": 4,
                        "question": "A ball dropped from 8 m rebounds to 3/4 of its height each bounce. What is the total downward distance over infinite bounces?",
                        "options": ["24 m", "32 m", "16 m", "40 m"],
                        "correct_index": 1,
                        "explanation": "Sum = 8 / (1 − 3/4) = 8 / (1/4) = 32 m."
                    }
                ]
            }
        # Level 9+: Calculus & Higher Analysis (Easy -> Harder)
        else:
            return {
                "topic": "Differentiation & The Chain Rule",
                "explanation": "Derivatives measure the instantaneous rate of change of a function. When differentiating a composite function y = f(g(x)), the chain rule states that dy/dx = f'(g(x)) · g'(x). For example, d/dx[sin(x²)] = cos(x²) · 2x. The chain rule is the mathematical cornerstone of backpropagation in deep neural networks and physics dynamics.",
                "questions": [
                    {
                        "id": 1,
                        "question": "What is the derivative d/dx[x³] using the power rule?",
                        "options": ["x²", "3x²", "3x³", "x⁴ / 4"],
                        "correct_index": 1,
                        "explanation": "By the power rule d/dx[xⁿ] = n·xⁿ⁻¹, d/dx[x³] = 3x²."
                    },
                    {
                        "id": 2,
                        "question": "Which differentiation rule is required to find the derivative of f(g(x))?",
                        "options": ["Product Rule", "Quotient Rule", "Chain Rule", "L'Hôpital's Rule"],
                        "correct_index": 2,
                        "explanation": "The chain rule handles composite functions: [f(g(x))]' = f'(g(x)) · g'(x)."
                    },
                    {
                        "id": 3,
                        "question": "Evaluate d/dx[(3x + 1)⁵].",
                        "options": ["5(3x + 1)⁴", "15(3x + 1)⁴", "5(3x + 1)⁵", "3(3x + 1)⁵"],
                        "correct_index": 1,
                        "explanation": "Outer derivative 5(3x+1)⁴ × inner derivative 3 = 15(3x + 1)⁴."
                    },
                    {
                        "id": 4,
                        "question": "Why is the chain rule essential in deep learning backpropagation?",
                        "options": ["Neural nets are linear", "Neural nets are deeply composed activation functions", "All neural weights are constant", "Loss functions are always zero"],
                        "correct_index": 1,
                        "explanation": "Backpropagation computes error gradients across composed layers using the chain rule."
                    }
                ]
            }
    else:
        tier_info = _get_curriculum_tier(req)
        first_topic = tier_info["topics"][0] if tier_info["topics"] else req.subject
        return {
            "topic": f"{first_topic} — {req.subject} Fundamentals",
            "explanation": f"Mastery of {req.subject} begins with its foundational principles. Break complex concepts into manageable steps, connect ideas through concrete examples, and verify your skills with active practice questions. Each lesson advances your mastery in the KnowledgeVerse Academy.",
            "questions": [
                {
                    "id": 1,
                    "question": f"What is the foundational approach to mastering {req.subject}?",
                    "options": ["Rote memorization", "Understanding core principles and active practice", "Skipping fundamentals", "Random guessing"],
                    "correct_index": 1,
                    "explanation": "Active practice with core concepts produces deep, durable understanding."
                },
                {
                    "id": 2,
                    "question": f"When solving complex problems in {req.subject}, what is the first step?",
                    "options": ["Break the problem into smaller solvable components", "Guess the final answer", "Ignore the given constraints", "Skip to another topic"],
                    "correct_index": 0,
                    "explanation": "Deconstructing problems reduces cognitive load and reveals solution pathways."
                },
                {
                    "id": 3,
                    "question": "How do practice problems reinforce learning?",
                    "options": ["They create active neural retrieval and verify comprehension", "They waste study time", "They only test short-term memory", "They have no effect"],
                    "correct_index": 0,
                    "explanation": "Active retrieval practice strengthens neural pathways for long-term retention."
                },
                {
                    "id": 4,
                    "question": "What is the best way to utilize feedback from incorrect answers?",
                    "options": ["Ignore it", "Analyze the reasoning gap and retry with the correct concept", "Give up on the subject", "Assume the test is wrong"],
                    "correct_index": 1,
                    "explanation": "Error analysis pinpoints conceptual misunderstandings and accelerates growth."
                }
            ]
        }


async def generate_learning_content(req: LearningRequest) -> LearningContentResponse:
    if not GEMINI_API_KEY:
        log.warning("No GEMINI_API_KEY configured, returning fallback learning content")
        fb = fallback_learning_content(req)
        raw_key = f"{req.building_id}_{req.subject}_{req.difficulty}_{req.student_level}"
        key = hashlib.sha256(raw_key.encode()).hexdigest()[:24]

        evict_if_full(text_cache)
        text_cache[key] = fb["explanation"]

        if ELEVENLABS_API_KEY:
            if key not in inflight:
                inflight[key] = asyncio.create_task(synthesize_audio(key, fb["explanation"]))

        return LearningContentResponse(
            building_id=req.building_id,
            building_name=req.building_name,
            subject=req.subject,
            topic=fb["topic"],
            explanation=fb["explanation"],
            questions=[MCQuestion(**q) for q in fb["questions"]],
            explanation_audio_url=f"/api/audio/{key}",
            audio_available=bool(ELEVENLABS_API_KEY),
            source="fallback",
            cache_key=key,
        )

    raw_key = f"{req.building_id}_{req.subject}_{req.difficulty}_{req.student_level}_{req.topic or ''}"
    key = hashlib.sha256(raw_key.encode()).hexdigest()[:24]

    prompt = build_learning_prompt(req)
    try:
        raw_response = await call_gemini(prompt)
        clean_json = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw_response.strip(), flags=re.MULTILINE)
        
        # Robust JSON parsing for math formulas (sanitize unescaped LaTeX backslashes)
        try:
            data = json.loads(clean_json, strict=False)
        except Exception:
            clean_fixed = re.sub(r'\\([a-zA-Z]+)', r'\1', clean_json)
            clean_fixed = re.sub(r'\\(?![/"\\bfnrtu])', r'\\\\', clean_fixed)
            data = json.loads(clean_fixed, strict=False)

        topic = data.get("topic", req.subject + " Essentials")
        explanation = data.get("explanation", "")
        raw_questions = data.get("questions", [])

        questions = []
        for i, q in enumerate(raw_questions[:4]):
            opts = [str(o) for o in q.get("options", [])]
            if len(opts) < 4:
                opts = opts + ["Option " + str(j) for j in range(len(opts), 4)]
            opts = opts[:4]

            raw_idx = None
            for k in ["correct_index", "correctindex", "correctIndex", "answer_index", "answerIndex", "answer", "correct"]:
                if k in q and q[k] is not None:
                    raw_idx = q[k]
                    break

            c_idx = 0
            if raw_idx is not None:
                try:
                    c_idx = int(raw_idx) % len(opts)
                except (ValueError, TypeError):
                    str_idx = str(raw_idx).strip().lower()
                    for opt_i, opt_val in enumerate(opts):
                        if str_idx == opt_val.strip().lower():
                            c_idx = opt_i
                            break

            expl = q.get("explanation", "Correct choice.")

            questions.append(
                MCQuestion(
                    id=q.get("id", i + 1),
                    question=q.get("question", f"Question {i+1}"),
                    options=opts,
                    correct_index=c_idx,
                    explanation=expl,
                )
            )

        while len(questions) < 4:
            idx = len(questions) + 1
            questions.append(
                MCQuestion(
                    id=idx,
                    question=f"Understanding check {idx} for {topic}",
                    options=["Correct Principle", "Alternative Concept", "Incorrect Option", "Unrelated Detail"],
                    correct_index=0,
                    explanation="Applies core conceptual principles.",
                )
            )

        evict_if_full(text_cache)
        text_cache[key] = explanation

        # Start asynchronous ElevenLabs TTS synthesis task
        if ELEVENLABS_API_KEY and explanation:
            if key not in inflight:
                task = asyncio.create_task(synthesize_audio(key, explanation))
                inflight[key] = task

        return LearningContentResponse(
            building_id=req.building_id,
            building_name=req.building_name,
            subject=req.subject,
            topic=topic,
            explanation=explanation,
            questions=questions,
            explanation_audio_url=f"/api/audio/{key}",
            audio_available=bool(ELEVENLABS_API_KEY),
            source="gemini",
            cache_key=key,
        )

    except Exception as exc:
        log.warning("Gemini AI failed for learning content, falling back: %s", exc)
        fb = fallback_learning_content(req)
        evict_if_full(text_cache)
        text_cache[key] = fb["explanation"]

        if ELEVENLABS_API_KEY:
            if key not in inflight:
                inflight[key] = asyncio.create_task(synthesize_audio(key, fb["explanation"]))

        return LearningContentResponse(
            building_id=req.building_id,
            building_name=req.building_name,
            subject=req.subject,
            topic=fb["topic"],
            explanation=fb["explanation"],
            questions=[MCQuestion(**q) for q in fb["questions"]],
            explanation_audio_url=f"/api/audio/{key}",
            audio_available=bool(ELEVENLABS_API_KEY),
            source="fallback",
            cache_key=key,
        )


async def generate_tts(req: TTSRequest) -> TTSResponse:
    if not ELEVENLABS_API_KEY:
        return TTSResponse(audio_url=None, audio_available=False, cache_key="")

    text = req.text.strip()
    if not text:
        raise HTTPException(400, "Text cannot be empty")

    key = hashlib.sha256(text.encode()).hexdigest()[:24]
    evict_if_full(text_cache)
    text_cache[key] = text

    if key in audio_cache:
        return TTSResponse(audio_url=f"/api/audio/{key}", audio_available=True, cache_key=key)

    try:
        audio = await synthesize_audio(key, text)
        return TTSResponse(audio_url=f"/api/audio/{key}", audio_available=True, cache_key=key)
    except Exception as exc:
        log.warning("TTS generation failed: %s", exc)

    return TTSResponse(audio_url=None, audio_available=False, cache_key=key)
