# CompVal — Computational Validation of Mathematical Results

Numerically validate a mathematical result (theorem, formula, identity, approximation, bound) by writing a Python simulation, running it in a clean virtual environment, and producing a publication-quality matplotlib figure showing the validation.

## Arguments

`<mathematical result to validate>` — The theorem, formula, identity, or claim to test numerically.

Examples:
- `/compval the Central Limit Theorem converges for n=1,5,10,30,100`
- `/compval Basel problem: sum of 1/n^2 = pi^2/6`
- `/compval Stirling's approximation n! ~ sqrt(2*pi*n)*(n/e)^n`
- `/compval that the eigenvalues of a random Wigner matrix follow the semicircle law`
- `/compval Monte Carlo estimate of pi converges at rate O(1/sqrt(n))`
- `/compval Cauchy-Schwarz inequality holds for random vectors in R^100`

If no arguments, ask the user what mathematical result they want to validate.

---

## Step 1: Understand the Result

Before writing any code, clarify:

1. **The claim** — State the mathematical result precisely. Write it in plain math notation.
2. **What "validation" means here** — What would a successful numerical test look like?
   - Convergence to a known value?
   - A bound holding across many samples?
   - A distribution matching a theoretical prediction?
   - An inequality never being violated?
3. **Error tolerance** — What numerical precision should we target?
   - Default: relative error < 1e-6 for exact results, or statistical consistency for probabilistic claims
   - Ask the user if they have a specific tolerance in mind
4. **Parameters** — What ranges, dimensions, sample sizes should we sweep?

If the result is well-known and clear from the arguments, skip straight to coding. Don't over-ask.

---

## Step 2: Set Up Environment

Create a clean virtual environment and install dependencies.

```bash
# Create project directory
mkdir -p ~/compval/<result-slug>
cd ~/compval/<result-slug>

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install scientific stack
pip install numpy scipy matplotlib
```

Install additional packages only if the result requires them:
- **sympy** — for symbolic verification alongside numerical
- **statsmodels** — for statistical tests
- **scikit-learn** — for ML-related validations
- **mpmath** — for arbitrary precision arithmetic
- **numba** — for performance-critical simulations

Keep it minimal. Don't install what you don't need.

---

## Step 3: Write the Validation Script

Create a single Python file: `~/compval/<result-slug>/validate_<slug>.py`

The script must follow this structure:

```python
"""
Computational Validation: <result name>
========================================
Claim: <precise mathematical statement>
Method: <brief description of numerical approach>
Tolerance: <error bound>
"""

import numpy as np
import matplotlib.pyplot as plt
# ... other imports as needed

# ─── Configuration ───────────────────────────────────
# Parameters, sample sizes, tolerances — all in one place
# Easy to tweak without reading the whole script

# ─── Numerical Computation ──────────────────────────
# The core simulation / computation
# Clear variable names, commented steps

# ─── Theoretical Reference ──────────────────────────
# Compute the known/expected analytical value
# This is what we compare the numerics against

# ─── Validation Check ───────────────────────────────
# Compare numerical result to theoretical
# Print PASS/FAIL with actual error vs tolerance

# ─── Visualization ──────────────────────────────────
# Publication-quality matplotlib figure
# Shows both numerical results and theoretical reference
```

### Code Quality Requirements

- **Reproducible** — set `np.random.seed(42)` for any stochastic simulation
- **Documented** — docstring at top, comments on non-obvious steps
- **Parameterized** — all magic numbers in a config section at the top
- **Robust** — handle edge cases (division by zero, overflow, empty arrays)
- **Print a verdict** — the script must print a clear PASS/FAIL summary to stdout

### Validation Output Format

The script must print:

```
══════════════════════════════════════════════
COMPUTATIONAL VALIDATION: <result name>
══════════════════════════════════════════════
Claim:      <mathematical statement>
Method:     <what the simulation does>
Samples:    <N>
Tolerance:  <epsilon>

Result:     <numerical value>
Expected:   <theoretical value>
Error:      <absolute and relative error>

Verdict:    ✓ PASS — within tolerance (or ✗ FAIL — exceeds tolerance)
══════════════════════════════════════════════
```

---

## Step 4: Create the Figure

The matplotlib figure should be **publication-quality**:

### Style
- Use `plt.style.use('seaborn-v0_8-whitegrid')` or a clean style
- Figure size: `(10, 6)` default, adjust for content
- DPI: 150 for saved file
- Font sizes: title 14pt, axis labels 12pt, tick labels 10pt
- Colors: use a proper colormap or distinct palette, not default rainbow

### Content (choose based on what fits the result)
- **Convergence plot** — numerical estimate vs N, with theoretical value as horizontal dashed line
- **Error plot** — log-log plot of error vs parameter, showing convergence rate
- **Distribution comparison** — histogram of numerical samples vs theoretical PDF overlay
- **Scatter/heatmap** — for inequality validations, show where the bound is tight
- **Multiple panels** — use subplots if multiple aspects need showing

### Required Elements
- Title stating what's being validated
- Axis labels with units/descriptions
- Legend distinguishing numerical vs theoretical
- Annotation showing final error or key metric
- Shaded region or error bars for confidence intervals (if stochastic)
- Tight layout: `plt.tight_layout()`

### Save
```python
plt.savefig('validation_<slug>.png', dpi=150, bbox_inches='tight')
plt.savefig('validation_<slug>.pdf', bbox_inches='tight')  # vector version
```

Save both PNG (for quick viewing) and PDF (for papers/presentations).

---

## Step 5: Run and Verify

```bash
cd ~/compval/<result-slug>
source .venv/bin/activate
python validate_<slug>.py
```

1. Check stdout for the PASS/FAIL verdict
2. Open the generated plot in Chrome to show the user
3. If FAIL:
   - Check for bugs in the script
   - Consider if the tolerance is too tight
   - Consider if the sample size is too small
   - Report honestly — a FAIL is a valid scientific result if the code is correct

---

## Step 6: Organize Output

```
~/compval/<result-slug>/
├── .venv/                          ← virtual environment (gitignored)
├── validate_<slug>.py              ← the validation script
├── validation_<slug>.png           ← matplotlib figure (raster)
├── validation_<slug>.pdf           ← matplotlib figure (vector)
└── README.md                       ← what was validated, result, how to run
```

Create a brief `README.md`:

```markdown
# Computational Validation: <Result Name>

## Claim
<Mathematical statement>

## Method
<What the simulation does>

## Result
<PASS/FAIL with error>

## How to Run
source .venv/bin/activate
python validate_<slug>.py

## Dependencies
numpy, scipy, matplotlib
```

---

## Final Report

```
Computational Validation Complete
═══════════════════════════════════════════
Result:         <mathematical claim>
Verdict:        ✓ PASS (or ✗ FAIL)
Error:          <value> (tolerance: <epsilon>)

Script:         ~/compval/<slug>/validate_<slug>.py
Figure (PNG):   ~/compval/<slug>/validation_<slug>.png
Figure (PDF):   ~/compval/<slug>/validation_<slug>.pdf
Environment:    ~/compval/<slug>/.venv/

Method:         <brief description>
Samples/Params: <N, dimensions, ranges>
Libraries:      numpy, scipy, matplotlib
═══════════════════════════════════════════
```

---

## Rules

1. **Honest results.** If the numerical test fails, report it. Don't fudge tolerances or cherry-pick parameters to force a PASS. A legitimate FAIL is scientifically valuable.
2. **Reproducible.** Set random seeds. Pin parameters. Anyone running the script should get the same result.
3. **Clean environment.** Always use a virtual environment. Never install into the system Python.
4. **One script, one result.** Each validation is a single self-contained .py file. No multi-file projects.
5. **Show your work.** The plot should make the validation visually obvious — a reader should understand PASS/FAIL from the figure alone without reading the code.
6. **Print the verdict.** The script must print PASS/FAIL to stdout. Don't make the user interpret raw numbers.
7. **Both raster and vector.** Save PNG for quick viewing and PDF for publication.
8. **Minimal dependencies.** numpy + scipy + matplotlib covers 95% of cases. Only add more if truly needed.
9. **Preview the plot.** Open the PNG in Chrome so the user can see it before declaring done.
