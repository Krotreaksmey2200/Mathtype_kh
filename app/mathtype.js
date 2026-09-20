/**
 * MathType 7 (64-bit Apple Silicon Edition)
 * With Khmer Math Editor Features & Direct Word AppleScript Integration
 */

let mf = null;
let currentActivePalette = null;
let currentZoom = 1.0;
let currentLang = 'km'; // 'km' or 'en'

// Language dictionaries
const i18n = {
  km: {
    menuFile: "ឯកសារ",
    menuNew: "បង្កើតសមីការថ្មី",
    menuInsertWord: "បញ្ចូលទៅ Word",
    menuSavePNG: "រក្សាទុកជារូបភាព PNG...",
    menuSaveSVG: "រក្សាទុកជា SVG Vector...",
    menuSavePDF: "រក្សាទុកជា Vector PDF...",
    menuSaveLaTeX: "រក្សាទុកជា LaTeX...",
    menuPrint: "បោះពុម្ព...",
    menuClose: "បិទផ្ទាំង",
    menuEdit: "កែប្រែ",
    menuCopyWord: "ចម្លងទៅ Word",
    menuView: "បង្ហាញ",
    menuStyle: "រចនាបថ",
    menuHelp: "ជំនួយ",
    labelOpenWord: "បើក Word",
    labelInsertWord: "បញ្ចូលទៅ Word",
    labelCopyWord: "ចម្លង",
    labelClear: "សម្អាត",
    labelHistory: "ប្រវត្តិ",
    labelFavorites: "សំណព្វ",
    tabChem: "🧪 គីមីវិទ្យា",
    menuCheckUpdates: "🔄 ពិនិត្យមើលកំណែថ្មី...",
    statusReady: "ត្រៀមរួចរាល់",
    statusInserted: "✓ បានបញ្ចូលសមីការទៅកាន់ Word ដោយជោគជ័យ!",
    statusCopied: "✓ បានចម្លងរូបមន្តរួចរាល់! អាចចុច ⌘V ក្នុង Word",
    langBtn: "🇰🇭 ខ្មែរ"
  },
  en: {
    menuFile: "File",
    menuNew: "New Equation",
    menuInsertWord: "Insert into Word",
    menuSavePNG: "Save as PNG Image...",
    menuSaveSVG: "Save as SVG Vector...",
    menuSavePDF: "Save as Vector PDF...",
    menuSaveLaTeX: "Save as LaTeX...",
    menuPrint: "Print...",
    menuClose: "Close Window",
    menuEdit: "Edit",
    menuCopyWord: "Copy to Word",
    menuView: "View",
    menuStyle: "Style",
    menuHelp: "Help",
    labelOpenWord: "Open Word",
    labelInsertWord: "Insert into Word",
    labelCopyWord: "Copy",
    labelClear: "Clear",
    labelHistory: "History",
    labelFavorites: "Favorites",
    tabChem: "🧪 Chemistry",
    menuCheckUpdates: "🔄 Check for Updates...",
    statusReady: "Ready",
    statusInserted: "✓ Successfully inserted equation into Microsoft Word!",
    statusCopied: "✓ Copied equation! Now press ⌘V in Word.",
    langBtn: "🇺🇸 English"
  }
};

// ============================================================================
// 1. PALETTE DEFINITIONS (10 Symbol Palettes & 10 Template Palettes)
// ============================================================================

const SYMBOL_PALETTES = [
  {
    id: "relational",
    title: "Relational Symbols (សញ្ញាទំនាក់ទំនង)",
    iconImg: "749.gif",
    fallbackText: "≤ ≠",
    items: [
      { label: "≤", desc: "Less-than or equal to (តូចជាង ឬស្មើ)", latex: "\\le " },
      { label: "≥", desc: "Greater-than or equal to (ធំជាង ឬស្មើ)", latex: "\\ge " },
      { label: "<", desc: "Less than (តូចជាង)", latex: "<" },
      { label: ">", desc: "Greater than (ធំជាង)", latex: ">" },
      { label: "≠", desc: "Not equal to (មិនស្មើ)", latex: "\\ne " },
      { label: "≈", desc: "Almost equal to (ប្រហែលស្មើ)", latex: "\\approx " },
      { label: "≡", desc: "Identical to / Equivalent (សមមូល)", latex: "\\equiv " },
      { label: "∼", desc: "Similar to (ដូចគ្នា)", latex: "\\sim " },
      { label: "≃", desc: "Asymptotically equal to", latex: "\\simeq " },
      { label: "≪", desc: "Much less-than", latex: "\\ll " },
      { label: "≫", desc: "Much greater-than", latex: "\\gg " },
      { label: "∝", desc: "Proportional to (សមាមាត្រ)", latex: "\\propto " },
      { label: "≅", desc: "Congruent to (ប៉ុនគ្នា)", latex: "\\cong " },
      { label: "≐", desc: "Approaches limit", latex: "\\doteq " },
      { label: "∥", desc: "Parallel to (ស្រប)", latex: "\\parallel " },
      { label: "⊥", desc: "Perpendicular to (កែង)", latex: "\\perp " }
    ]
  },
  {
    id: "spaces",
    title: "Spaces and Ellipses",
    iconImg: "750.gif",
    fallbackText: "…  ",
    items: [
      { label: "·", desc: "Zero space", latex: "\\," },
      { label: "Thin", desc: "Thin space", latex: "\\," },
      { label: "Med", desc: "Medium space", latex: "\\:" },
      { label: "Thick", desc: "Thick space", latex: "\\;" },
      { label: "Quad", desc: "Quad space", latex: "\\quad " },
      { label: "Qquad", desc: "Double quad space", latex: "\\qquad " },
      { label: "…", desc: "Horizontal ellipsis", latex: "\\dots " },
      { label: "⋯", desc: "Centered horizontal ellipsis", latex: "\\cdots " },
      { label: "⋮", desc: "Vertical ellipsis", latex: "\\vdots " },
      { label: "⋱", desc: "Diagonal ellipsis", latex: "\\ddots " }
    ]
  },
  {
    id: "embellishments",
    title: "Embellishments (សញ្ញាបន្ថែមលើអថេរ)",
    iconImg: "751.gif",
    fallbackText: "x̄ x⃗",
    items: [
      { label: "x̂", desc: "Hat accent", latex: "\\hat{#@}" },
      { label: "x̄", desc: "Bar / Overbar accent", latex: "\\bar{#@}" },
      { label: "x⃗", desc: "Right arrow accent (វ៉ិចទ័រ)", latex: "\\vec{#@}" },
      { label: "ẋ", desc: "Single dot", latex: "\\dot{#@}" },
      { label: "ẍ", desc: "Double dot", latex: "\\ddot{#@}" },
      { label: "x̃", desc: "Tilde accent", latex: "\\tilde{#@}" },
      { label: "x′", desc: "Prime", latex: "^{\\prime}" },
      { label: "x″", desc: "Double prime", latex: "^{\\prime\\prime}" },
      { label: "x*", desc: "Asterisk / Star", latex: "^{*}" }
    ]
  },
  {
    id: "operators",
    title: "Operator Symbols (ប្រមាណវិធី)",
    iconImg: "752.gif",
    fallbackText: "+ − ×",
    items: [
      { label: "±", desc: "Plus-or-minus (បូកដក)", latex: "\\pm " },
      { label: "∓", desc: "Minus-or-plus", latex: "\\mp " },
      { label: "×", desc: "Multiplication cross (គុណ)", latex: "\\times " },
      { label: "÷", desc: "Division sign (ចែក)", latex: "\\div " },
      { label: "·", desc: "Center dot (ចុចគុណ)", latex: "\\cdot " },
      { label: "∗", desc: "Asterisk operator", latex: "\\ast " },
      { label: "★", desc: "Star operator", latex: "\\star " },
      { label: "∘", desc: "Composite function", latex: "\\circ " },
      { label: "•", desc: "Bullet operator", latex: "\\bullet " },
      { label: "⊕", desc: "Direct sum", latex: "\\oplus " },
      { label: "⊗", desc: "Tensor product", latex: "\\otimes " }
    ]
  },
  {
    id: "arrows",
    title: "Arrow Symbols (ព្រួញ)",
    iconImg: "753.gif",
    fallbackText: "← →",
    items: [
      { label: "←", desc: "Left arrow", latex: "\\leftarrow " },
      { label: "→", desc: "Right arrow", latex: "\\rightarrow " },
      { label: "↔", desc: "Left-right arrow", latex: "\\leftrightarrow " },
      { label: "↑", desc: "Up arrow (ឧស្ម័ន)", latex: "\\uparrow " },
      { label: "↓", desc: "Down arrow (កករ)", latex: "\\downarrow " },
      { label: "⇌", desc: "Equilibrium arrow (លំនឹងគីមី)", latex: "\\rightleftharpoons " },
      { label: "⇐", desc: "Double left arrow", latex: "\\Leftarrow " },
      { label: "⇒", desc: "Implies (នាំឱ្យ)", latex: "\\Rightarrow " },
      { label: "⇔", desc: "Equivalence (សមមូល)", latex: "\\Leftrightarrow " },
      { label: "↦", desc: "Maps to", latex: "\\mapsto " }
    ]
  },
  {
    id: "logical",
    title: "Logical Symbols (តក្កវិទ្យា)",
    iconImg: "754.gif",
    fallbackText: "∀ ∃",
    items: [
      { label: "∀", desc: "For all (គ្រប់)", latex: "\\forall " },
      { label: "∃", desc: "There exists (មាន)", latex: "\\exists " },
      { label: "∄", desc: "There does not exist", latex: "\\nexists " },
      { label: "¬", desc: "Logical NOT (មិន)", latex: "\\neg " },
      { label: "∧", desc: "Logical AND (និង)", latex: "\\land " },
      { label: "∨", desc: "Logical OR (ឬ)", latex: "\\lor " },
      { label: "∴", desc: "Therefore (ដូចនេះ)", latex: "\\therefore " },
      { label: "∵", desc: "Because (ពីព្រោះ)", latex: "\\because " }
    ]
  },
  {
    id: "sets",
    title: "Set Theory Symbols (សំណុំ)",
    iconImg: "755.gif",
    fallbackText: "∈ ∪",
    items: [
      { label: "∈", desc: "Element of (ជារបស់)", latex: "\\in " },
      { label: "∉", desc: "Not an element of (មិនជារបស់)", latex: "\\notin " },
      { label: "∋", desc: "Contains as member", latex: "\\ni " },
      { label: "⊂", desc: "Proper subset of (ជាផ្នែក)", latex: "\\subset " },
      { label: "⊃", desc: "Proper superset of", latex: "\\supset " },
      { label: "⊆", desc: "Subset of or equal to", latex: "\\subseteq " },
      { label: "⊇", desc: "Superset of or equal to", latex: "\\supseteq " },
      { label: "∪", desc: "Union (ប្រជុំ)", latex: "\\cup " },
      { label: "∩", desc: "Intersection (ប្រសព្វ)", latex: "\\cap " },
      { label: "∖", desc: "Set difference (ដកសំណុំ)", latex: "\\setminus " },
      { label: "∅", desc: "Empty set (សំណុំទទេ)", latex: "\\emptyset " },
      { label: "ℝ", desc: "Real numbers (ចំនួនពិត)", latex: "\\mathbb{R}" },
      { label: "ℕ", desc: "Natural numbers (ចំនួនគត់ធម្មជាតិ)", latex: "\\mathbb{N}" },
      { label: "ℤ", desc: "Integers (ចំនួនគត់រឺឡាទីប)", latex: "\\mathbb{Z}" },
      { label: "ℂ", desc: "Complex numbers (ចំនួនកុំផ្លិច)", latex: "\\mathbb{C}" },
      { label: "ℚ", desc: "Rational numbers (ចំនួនសនិទាន)", latex: "\\mathbb{Q}" }
    ]
  },
  {
    id: "misc",
    title: "Miscellaneous Symbols",
    iconImg: "756.gif",
    fallbackText: "∞ ∂",
    items: [
      { label: "∞", desc: "Infinity (អនន្ត)", latex: "\\infty " },
      { label: "∂", desc: "Partial derivative", latex: "\\partial " },
      { label: "∇", desc: "Nabla / Del / Gradient", latex: "\\nabla " },
      { label: "ℏ", desc: "Planck's constant", latex: "\\hbar " },
      { label: "∠", desc: "Angle (មុំ)", latex: "\\angle " },
      { label: "△", desc: "Triangle (ត្រីកោណ)", latex: "\\triangle " },
      { label: "°", desc: "Degree (ដឺក្រេ)", latex: "^\\circ " }
    ]
  },
  {
    id: "greek_lower",
    title: "Greek Characters (Lowercase) (អក្សរក្រិកតូច)",
    iconImg: "757.gif",
    fallbackText: "α β",
    items: [
      { label: "α", desc: "alpha", latex: "\\alpha " },
      { label: "β", desc: "beta", latex: "\\beta " },
      { label: "γ", desc: "gamma", latex: "\\gamma " },
      { label: "δ", desc: "delta", latex: "\\delta " },
      { label: "ε", desc: "epsilon", latex: "\\epsilon " },
      { label: "ζ", desc: "zeta", latex: "\\zeta " },
      { label: "η", desc: "eta", latex: "\\eta " },
      { label: "θ", desc: "theta", latex: "\\theta " },
      { label: "λ", desc: "lambda", latex: "\\lambda " },
      { label: "μ", desc: "mu", latex: "\\mu " },
      { label: "π", desc: "pi", latex: "\\pi " },
      { label: "ρ", desc: "rho", latex: "\\rho " },
      { label: "σ", desc: "sigma", latex: "\\sigma " },
      { label: "τ", desc: "tau", latex: "\\tau " },
      { label: "ϕ", desc: "phi", latex: "\\phi " },
      { label: "ω", desc: "omega", latex: "\\omega " }
    ]
  },
  {
    id: "greek_upper",
    title: "Greek Characters (Uppercase) (អក្សរក្រិកធំ)",
    iconImg: "758.gif",
    fallbackText: "Γ Δ",
    items: [
      { label: "Γ", desc: "Gamma", latex: "\\Gamma " },
      { label: "Δ", desc: "Delta (ដែលតា)", latex: "\\Delta " },
      { label: "Θ", desc: "Theta", latex: "\\Theta " },
      { label: "Λ", desc: "Lambda", latex: "\\Lambda " },
      { label: "Π", desc: "Pi", latex: "\\Pi " },
      { label: "Σ", desc: "Sigma", latex: "\\Sigma " },
      { label: "Φ", desc: "Phi", latex: "\\Phi " },
      { label: "Ω", desc: "Omega", latex: "\\Omega " }
    ]
  }
];

const TEMPLATE_PALETTES = [
  {
    id: "fences",
    title: "Fence Templates (វង់ក្រចក / តង្កៀប)",
    iconImg: "994.gif",
    fallbackText: "( ) [ ]",
    items: [
      { label: "(□)", desc: "Parentheses (វង់ក្រចក)", latex: "\\left(#?\\right)" },
      { label: "[□]", desc: "Brackets (វង់ក្រចកជ្រុង)", latex: "\\left[#?\\right]" },
      { label: "{□}", desc: "Braces (តង្កៀប)", latex: "\\left\\{#?\\right\\}" },
      { label: "|□|", desc: "Absolute value (តម្លៃដាច់ខាត)", latex: "\\left|#?\\right|" },
      { label: "‖□‖", desc: "Norm / Double bars", latex: "\\left\\|#?\\right\\|" },
      { label: "⟨□⟩", desc: "Angle brackets", latex: "\\left\\langle#?\\right\\rangle" }
    ]
  },
  {
    id: "fractions_radicals",
    title: "Fraction and Radical Templates (ប្រភាគ និងឬស)",
    iconImg: "995.gif",
    fallbackText: "a/b √",
    items: [
      { label: "a/b", desc: "Full-size vertical fraction (ប្រភាគបញ្ឈរ) [⌘F]", latex: "\\frac{#?}{#0}" },
      { label: "a/b", desc: "Slash fraction", latex: "{#?}/{#0}" },
      { label: "√□", desc: "Square root (ឬសការេ) [⌘R]", latex: "\\sqrt{#?}" },
      { label: "ⁿ√□", desc: "Root with index (ឬសទី n) [⇧⌘R]", latex: "\\sqrt[#0]{#?}" }
    ]
  },
  {
    id: "sub_superscript",
    title: "Subscript and Superscript (ស្វ័យគុណ និងសន្ទស្សន៍)",
    iconImg: "996.gif",
    fallbackText: "xⁿ xₙ",
    items: [
      { label: "xⁿ", desc: "Superscript / Exponent (ស្វ័យគុណ) [⌘H]", latex: "^{#?}" },
      { label: "xₙ", desc: "Subscript (សន្ទស្សន៍) [⌘L]", latex: "_{#?}" },
      { label: "xₙⁿ", desc: "Superscript & subscript [⌘J]", latex: "_{#0}^{#?}" }
    ]
  },
  {
    id: "summations",
    title: "Summation Templates (ផលបូក)",
    iconImg: "997.gif",
    fallbackText: "∑",
    items: [
      { label: "∑ₙᵐ", desc: "Summation with limits", latex: "\\sum_{#0}^{#?}" },
      { label: "∑ₙ", desc: "Summation with underscript", latex: "\\sum_{#?}" },
      { label: "∑", desc: "Summation without limits", latex: "\\sum " }
    ]
  },
  {
    id: "integrals",
    title: "Integral Templates (អាំងតេក្រាល)",
    iconImg: "998.gif",
    fallbackText: "∫",
    items: [
      { label: "∫", desc: "Indefinite integral", latex: "\\int #? \\, d#0" },
      { label: "∫ₐᵇ", desc: "Definite integral with limits", latex: "\\int_{#0}^{#?} #1 \\, d#2" },
      { label: "∬", desc: "Double integral", latex: "\\iint #? \\, dA" },
      { label: "∮", desc: "Contour integral", latex: "\\oint #? \\, ds" }
    ]
  },
  {
    id: "under_overbar",
    title: "Underbar and Overbar Templates",
    iconImg: "999.gif",
    fallbackText: "x̄ x̲",
    items: [
      { label: "x̄", desc: "Overbar", latex: "\\overline{#?}" },
      { label: "x̲", desc: "Underbar", latex: "\\underline{#?}" },
      { label: "⏞", desc: "Overbrace", latex: "\\overbrace{#?}^{#0}" },
      { label: "⏟", desc: "Underbrace", latex: "\\underbrace{#?}_{#0}" }
    ]
  },
  {
    id: "labeled_arrows",
    title: "Labeled Arrow Templates",
    iconImg: "1000.gif",
    fallbackText: "→ f",
    items: [
      { label: "→ᶠ", desc: "Right arrow with text over", latex: "\\xrightarrow{#?}" },
      { label: "←ᵍ", desc: "Left arrow with text over", latex: "\\xleftarrow{#?}" }
    ]
  },
  {
    id: "products_set_theory",
    title: "Products and Set Theory Templates",
    iconImg: "1001.gif",
    fallbackText: "∏ ⋃",
    items: [
      { label: "∏ₙᵐ", desc: "Product with limits (ផលគុណ)", latex: "\\prod_{#0}^{#?}" },
      { label: "∏", desc: "Product without limits", latex: "\\prod " },
      { label: "⋂", desc: "Intersection with limits", latex: "\\bigcap_{#0}^{#?}" },
      { label: "⋃", desc: "Union with limits", latex: "\\bigcup_{#0}^{#?}" }
    ]
  },
  {
    id: "matrices",
    title: "Matrix Templates (ម៉ាទ្រីស)",
    iconImg: "1002.gif",
    fallbackText: "[::]",
    items: [
      { label: "2×2", desc: "2x2 matrix with brackets", latex: "\\begin{bmatrix} #? & #0 \\\\ #1 & #2 \\end{bmatrix}" },
      { label: "(2×2)", desc: "2x2 matrix with parentheses", latex: "\\begin{pmatrix} #? & #0 \\\\ #1 & #2 \\end{pmatrix}" },
      { label: "|2×2|", desc: "2x2 determinant (ដេទែមីណង់)", latex: "\\begin{vmatrix} #? & #0 \\\\ #1 & #2 \\end{vmatrix}" },
      { label: "3×3", desc: "3x3 matrix", latex: "\\begin{bmatrix} #? & #0 & #1 \\\\ #2 & #3 & #4 \\\\ #5 & #6 & #7 \\end{bmatrix}" },
      { label: "1×2", desc: "Row vector (1x2)", latex: "\\begin{bmatrix} #? & #0 \\end{bmatrix}" },
      { label: "2×1", desc: "Column vector (2x1)", latex: "\\begin{bmatrix} #? \\\\ #0 \\end{bmatrix}" }
    ]
  },
  {
    id: "boxes",
    title: "Box Templates",
    iconImg: "1003.gif",
    fallbackText: "□",
    items: [
      { label: "□", desc: "Boxed expression", latex: "\\boxed{#?}" }
    ]
  }
];

// ============================================================================
// 2. TABBED EXPRESSIONS BAR DATA
// ============================================================================

const TABBED_EXPRESSIONS = {
  algebra: [
    { label: "x = (-b ± √(b²-4ac)) / 2a", desc: "Quadratic formula (រូបមន្តសមីការដឺក្រេទី២)", latex: "x=\\frac{-b\\pm\\sqrt{b^{2}-4ac}}{2a}" },
    { label: "a² + b² = c²", desc: "Pythagorean theorem (ទ្រឹស្តីបទពីតាករ)", latex: "a^{2}+b^{2}=c^{2}" },
    { label: "(a+b)ⁿ = ∑", desc: "Binomial theorem (ទ្រឹស្តីបទញូតុន)", latex: "(a+b)^{n}=\\sum_{k=0}^{n}\\binom{n}{k}a^{n-k}b^{k}" },
    { label: "d = √((x₂-x₁)²+(y₂-y₁)²)", desc: "Distance formula (ចម្ងាយរវាងពីរចំណុច)", latex: "d=\\sqrt{(x_{2}-x_{1})^{2}+(y_{2}-y_{1})^{2}}" },
    { label: "Linear System", desc: "2-equation linear system (ប្រព័ន្ធសមីការ)", latex: "\\begin{cases}ax+by=c\\\\dx+ey=f\\end{cases}" }
  ],
  derivs: [
    { label: "f'(x) = lim (f(x+h)-f(x))/h", desc: "Definition of derivative (និយមន័យដេរីវេ)", latex: "f'(x)=\\lim_{h\\to0}\\frac{f(x+h)-f(x)}{h}" },
    { label: "(uv)' = u'v + uv'", desc: "Product rule", latex: "(uv)'=u'v+uv'" },
    { label: "(u/v)' = (u'v-uv')/v²", desc: "Quotient rule", latex: "\\left(\\frac{u}{v}\\right)'=\\frac{u'v-uv'}{v^{2}}" },
    { label: "df/dx = df/du · du/dx", desc: "Chain rule", latex: "\\frac{df}{dx}=\\frac{df}{du}\\frac{du}{dx}" },
    { label: "d/dx [eˣ] = eˣ", desc: "Exponential derivative", latex: "\\frac{d}{dx}\\left[e^{x}\\right]=e^{x}" }
  ],
  statistics: [
    { label: "f(x) = (1/σ√(2π)) e^...", desc: "Normal distribution PDF (បំណែងចែកធម្មតា)", latex: "f(x)=\\frac{1}{\\sigma\\sqrt{2\\pi}}e^{-\\frac{1}{2}\\left(\\frac{x-\\mu}{\\sigma}\\right)^{2}}" },
    { label: "x̄ = 1/n ∑ xᵢ", desc: "Sample mean (មធ្យមភាគ)", latex: "\\bar{x}=\\frac{1}{n}\\sum_{i=1}^{n}x_{i}" },
    { label: "s = √(1/(n-1) ∑(xᵢ-x̄)²)", desc: "Sample standard deviation (គម្លាតស្តង់ដារ)", latex: "s=\\sqrt{\\frac{1}{n-1}\\sum_{i=1}^{n}(x_{i}-\\bar{x})^{2}}" }
  ],
  matrices: [
    { label: "[A] = [[a, b], [c, d]]", desc: "2x2 matrix", latex: "\\begin{bmatrix}a&b\\\\c&d\\end{bmatrix}" },
    { label: "det(A) = ad - bc", desc: "Determinant 2x2", latex: "\\begin{vmatrix}a&b\\\\c&d\\end{vmatrix}=ad-bc" },
    { label: "I = [[1, 0], [0, 1]]", desc: "Identity matrix", latex: "I=\\begin{bmatrix}1&0\\\\0&1\\end{bmatrix}" }
  ],
  sets: [
    { label: "(A ∪ B)' = A' ∩ B'", desc: "De Morgan's law 1", latex: "(A\\cup B)'=A'\\cap B'" },
    { label: "A × B = {(a,b) | a∈A, b∈B}", desc: "Cartesian product", latex: "A\\times B=\\{(a,b)\\mid a\\in A,\\,b\\in B\\}" }
  ],
  trig: [
    { label: "sin²θ + cos²θ = 1", desc: "Fundamental identity", latex: "\\sin^{2}\\theta+\\cos^{2}\\theta=1" },
    { label: "tanθ = sinθ / cosθ", desc: "Tangent identity", latex: "\\tan\\theta=\\frac{\\sin\\theta}{\\cos\\theta}" },
    { label: "e^(iθ) = cosθ + i sinθ", desc: "Euler's formula", latex: "e^{i\\theta}=\\cos\\theta+i\\sin\\theta" }
  ],
  geometry: [
    { label: "A = π r²", desc: "Area of a circle (ក្រឡាផ្ទៃរង្វង់)", latex: "A=\\pi r^{2}" },
    { label: "V = (4/3) π r³", desc: "Volume of a sphere (មាឌស្វ៊ែរ)", latex: "V=\\frac{4}{3}\\pi r^{3}" }
  ],
  chemistry: [
    { label: "2H₂ + O₂ → 2H₂O", desc: "Water synthesis (សំយោគទឹក)", latex: "\\text{2H}_2+\\text{O}_2\\rightarrow\\text{2H}_2\\text{O}" },
    { label: "CaCO₃ → CaO + CO₂↑", desc: "Thermal decomposition (រំលាយកម្ដៅ)", latex: "\\text{CaCO}_3\\xrightarrow{\\Delta}\\text{CaO}+\\text{CO}_2\\uparrow" },
    { label: "Ag⁺ + Cl⁻ → AgCl↓", desc: "Precipitation reaction (កករ)", latex: "\\text{Ag}^++\\text{Cl}^-\\rightarrow\\text{AgCl}\\downarrow" },
    { label: "N₂ + 3H₂ ⇌ 2NH₃", desc: "Chemical equilibrium (លំនឹងគីមី)", latex: "\\text{N}_2+\\text{3H}_2\\rightleftharpoons\\text{2NH}_3" },
    { label: "pH = -log[H⁺]", desc: "pH formula (រូបមន្ត pH)", latex: "\\text{pH}=-\\log[\\text{H}^+]" },
    { label: "CH₄ + 2O₂ → CO₂ + 2H₂O", desc: "Combustion (ចំហេះមេតាន)", latex: "\\text{CH}_4+\\text{2O}_2\\rightarrow\\text{CO}_2+\\text{2H}_2\\text{O}" },
    { label: "SO₄²⁻ / Fe³⁺", desc: "Polyatomic ions (អ៊ីយ៉ុង)", latex: "\\text{SO}_4^{2-},\\;\\text{Fe}^{3+}" }
  ]
};

// ============================================================================
// 3. APPLICATION INITIALIZATION
// ============================================================================

window.addEventListener("DOMContentLoaded", () => {
  mf = document.getElementById("mathField");

  // Start with clean empty canvas
  mf.setValue("");

  renderPalettes();
  switchTab("algebra");
  setupGlobalEvents();
  setupShortcuts();
  applyLanguage();
  setEquationSize(12);
  setZoom(1.0);

  setTimeout(() => mf.focus(), 150);
});

// ============================================================================
// 4. RENDERING & LOCALIZATION
// ============================================================================

function toggleLanguage() {
  currentLang = currentLang === 'km' ? 'en' : 'km';
  applyLanguage();
}

function applyLanguage() {
  const dict = i18n[currentLang];
  document.getElementById("langToggleBtn").innerText = dict.langBtn;
  document.getElementById("menuFile").innerText = dict.menuFile;
  document.getElementById("menuNew").innerText = dict.menuNew;
  document.getElementById("menuInsertWord").innerText = dict.menuInsertWord;
  document.getElementById("menuSavePNG").innerText = dict.menuSavePNG;
  const svgMenu = document.getElementById("menuSaveSVG");
  if (svgMenu) svgMenu.innerText = dict.menuSaveSVG;
  const pdfMenu = document.getElementById("menuSavePDF");
  if (pdfMenu) pdfMenu.innerText = dict.menuSavePDF;
  document.getElementById("menuSaveLaTeX").innerText = dict.menuSaveLaTeX;
  document.getElementById("menuPrint").innerText = dict.menuPrint;
  document.getElementById("menuClose").innerText = dict.menuClose;
  document.getElementById("menuEdit").innerText = dict.menuEdit;
  document.getElementById("menuCopyWord").innerText = dict.menuCopyWord;
  document.getElementById("menuView").innerText = dict.menuView;
  document.getElementById("menuStyle").innerText = dict.menuStyle;
  document.getElementById("menuHelp").innerText = dict.menuHelp;
  const checkUpdMenu = document.getElementById("menuCheckUpdates");
  if (checkUpdMenu) checkUpdMenu.innerText = dict.menuCheckUpdates;

  document.getElementById("labelOpenWord").innerText = dict.labelOpenWord;
  document.getElementById("labelInsertWord").innerText = dict.labelInsertWord;
  document.getElementById("labelCopyWord").innerText = dict.labelCopyWord;
  document.getElementById("labelClear").innerText = dict.labelClear;
  const lblHist = document.getElementById("labelHistory");
  if (lblHist) lblHist.innerText = dict.labelHistory;
  const lblFav = document.getElementById("labelFavorites");
  if (lblFav) lblFav.innerText = dict.labelFavorites;
  const tabCh = document.getElementById("tabChem");
  if (tabCh) tabCh.innerText = dict.tabChem;
  document.getElementById("statusMessage").innerText = dict.statusReady;
}

function renderPalettes() {
  const symRow = document.getElementById("symbolPalettesRow");
  const tmplRow = document.getElementById("templatePalettesRow");

  SYMBOL_PALETTES.forEach(pal => symRow.appendChild(createPaletteButton(pal, "symbol")));
  TEMPLATE_PALETTES.forEach(pal => tmplRow.appendChild(createPaletteButton(pal, "template")));

  const tabBtns = document.querySelectorAll(".tab-btn");
  tabBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      tabBtns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      switchTab(btn.dataset.tab);
    });
  });
}

function createPaletteButton(pal, type) {
  const btn = document.createElement("button");
  btn.className = "palette-btn";
  btn.title = pal.title;
  btn.dataset.paletteId = pal.id;
  btn.dataset.type = type;

  const iconPath = `./assets/icons/${pal.iconImg}`;
  const img = document.createElement("img");
  img.src = iconPath;
  img.alt = pal.title;
  img.onerror = () => {
    img.remove();
    const span = document.createElement("span");
    span.className = "palette-fallback-icon";
    span.innerText = pal.fallbackText;
    btn.insertBefore(span, arrow);
  };

  const arrow = document.createElement("div");
  arrow.className = "arrow-down";

  btn.appendChild(img);
  btn.appendChild(arrow);

  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    togglePalettePopup(btn, pal);
  });

  btn.addEventListener("mouseenter", () => showStatus(pal.title));
  btn.addEventListener("mouseleave", () => showStatus(i18n[currentLang].statusReady));

  return btn;
}

function cleanLatexForKaTeX(latex) {
  if (!latex) return "";
  let s = latex.trim();

  // Accents with selection placeholder #@ or missing base:
  // e.g. \hat{#@}, \bar{#@}, \vec{#@}, \dot{#@}, \ddot{#@}, \tilde{#@} -> \hat{\square}
  s = s.replace(/\\(hat|bar|vec|dot|ddot|tilde|acute|grave|check|breve)\{#@\}/g, "\\$1{\\square}");
  s = s.replace(/\\(hat|bar|vec|dot|ddot|tilde|acute|grave|check|breve)\{\s*\}/g, "\\$1{\\square}");

  // Standalone superscripts / subscripts without a base:
  // e.g. ^{#?}, _{#?}, _{#0}^{#?}, ^{\prime}, ^{\prime\prime}, ^{*}
  if (/^\s*[_^]/.test(s)) {
    s = "\\square" + s;
  }

  // Replace all MathLive placeholder tokens (#?, #@, #0, #1, #2, #3, etc.) with \square
  s = s.replace(/#[\?@\d]/g, "\\square");

  return s;
}

function renderMathPreview(latex, fallbackLabel) {
  if (!window.katex || !latex) {
    return fallbackLabel;
  }
  try {
    const clean = cleanLatexForKaTeX(latex);
    const rendered = katex.renderToString(clean, {
      displayMode: false,
      throwOnError: false
    });
    // Critical safeguard: Never display raw red LaTeX error code to the user
    if (rendered.includes("katex-error")) {
      return fallbackLabel;
    }
    return rendered;
  } catch (e) {
    return fallbackLabel;
  }
}

function togglePalettePopup(btn, pal) {
  const popup = document.getElementById("palettePopup");
  const grid = document.getElementById("popupGrid");

  if (currentActivePalette === pal.id && !popup.classList.contains("hidden")) {
    closePopup();
    return;
  }

  currentActivePalette = pal.id;
  grid.innerHTML = "";

  // Dynamic responsive columns based on item count for clean aesthetic layout
  let cols = 6;
  if (pal.items.length <= 4) {
    cols = pal.items.length;
  } else if (pal.items.length <= 6) {
    cols = 3;
  } else if (pal.items.length <= 9) {
    cols = 3;
  } else if (pal.items.length <= 12) {
    cols = 6;
  } else {
    cols = 8;
  }
  grid.style.gridTemplateColumns = `repeat(${cols}, auto)`;

  pal.items.forEach(item => {
    const div = document.createElement("div");
    div.className = "popup-item";
    div.title = item.desc;

    const span = document.createElement("span");
    span.innerHTML = renderMathPreview(item.latex, item.label);
    div.appendChild(span);

    div.addEventListener("click", (e) => {
      e.stopPropagation();
      insertLatex(item.latex);
      closePopup();
      mf.focus();
    });

    div.addEventListener("mouseenter", () => showStatus(item.desc));
    div.addEventListener("mouseleave", () => showStatus(pal.title));

    grid.appendChild(div);
  });

  popup.classList.remove("hidden");
  btn.classList.add("active");

  const rect = btn.getBoundingClientRect();
  const popupWidth = popup.offsetWidth || 180;
  let left = rect.left + window.scrollX;
  if (left + popupWidth > window.innerWidth - 10) {
    left = Math.max(10, window.innerWidth - popupWidth - 10);
  }
  popup.style.top = `${rect.bottom + window.scrollY + 2}px`;
  popup.style.left = `${left}px`;
}

function closePopup() {
  const popup = document.getElementById("palettePopup");
  popup.classList.add("hidden");
  document.querySelectorAll(".palette-btn").forEach(b => b.classList.remove("active"));
  currentActivePalette = null;
}

function switchTab(category) {
  const container = document.getElementById("tabsContent");
  container.innerHTML = "";

  const items = TABBED_EXPRESSIONS[category] || [];
  items.forEach(item => {
    const btn = document.createElement("button");
    btn.className = "expr-btn";
    btn.title = item.desc;

    // Render as real mathematical equation using KaTeX
    btn.innerHTML = renderMathPreview(item.latex, item.label);

    btn.addEventListener("click", () => {
      insertLatex(item.latex);
      mf.focus();
    });

    btn.addEventListener("mouseenter", () => showStatus(item.desc));
    btn.addEventListener("mouseleave", () => showStatus(i18n[currentLang].statusReady));

    container.appendChild(btn);
  });
}

// ============================================================================
// 5. EDITOR ACTIONS & SHORTCUTS
// ============================================================================

function insertLatex(latexStr) {
  if (!mf) return;
  mf.executeCommand(["insert", latexStr]);
}

function setupGlobalEvents() {
  document.addEventListener("click", (e) => {
    if (!e.target.closest("#palettePopup") && !e.target.closest(".palette-btn")) {
      closePopup();
    }
  });

  document.getElementById("canvasWrapper").addEventListener("click", () => {
    mf.focus();
  });
}

let currentEquationSize = 12;
let isAutoWord = true;

function setEquationSize(size) {
  currentEquationSize = parseFloat(size) || 12;
  const select = document.getElementById("equationSizeSelect");
  if (select) select.value = String(currentEquationSize);

  // Update Size menu checkmarks
  const menuSizes = [10, 11, 12, 13, 14, 16, 18, 20, 24, 28, 36];
  menuSizes.forEach(s => {
    const el = document.getElementById(`sizeMenu${s}`);
    if (el) {
      const label = s === 12 ? "✓ 12 pt (លំនាំដើម / Default)" : (s === currentEquationSize ? `✓ ${s} pt` : `${s} pt`);
      if (s === currentEquationSize) {
        el.classList.add("active-check");
        el.querySelector(".item-name").innerText = label.startsWith("✓") ? label : `✓ ${label}`;
      } else {
        el.classList.remove("active-check");
        el.querySelector(".item-name").innerText = s === 12 ? "12 pt (លំនាំដើម / Default)" : `${s} pt`;
      }
    }
  });

  // Adjust preview font size on canvas
  if (mf) {
    mf.style.fontSize = Math.max(20, currentEquationSize * 1.7) + "px";
  }
  showStatus(currentLang === 'km' ? `✓ ទំហំសមីការ៖ ${currentEquationSize} pt` : `✓ Equation size: ${currentEquationSize} pt`, true);
}

function toggleAutoWord(checked) {
  isAutoWord = checked;
  const pill = document.querySelector(".auto-word-pill");
  if (pill) {
    if (checked) pill.classList.add("active");
    else pill.classList.remove("active");
  }
  showStatus(isAutoWord ? 
    (currentLang === 'km' ? "✓ បើក Auto Word (ចុច Enter លោតចូល Word ភ្លាម)" : "✓ Auto Word Enabled (Press Enter to insert)") : 
    (currentLang === 'km' ? "បានបិទ Auto Word" : "Auto Word Disabled"), true);
}

function setupShortcuts() {
  window.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      closeModal();
      return;
    }

    const isCmdOrCtrl = e.metaKey || e.ctrlKey;

    // Option + Backslash (⌥\) or Option + T (⌥T) triggers Toggle TeX
    if (e.altKey && (e.key === "\\" || e.code === "Backslash" || e.key === "t" || e.key === "T")) {
      e.preventDefault();
      actionToggleTeX();
      return;
    }

    // Enter / Return triggers Auto Word Insertion if enabled or with Cmd
    if (e.key === "Enter") {
      if (isAutoWord || isCmdOrCtrl) {
        e.preventDefault();
        actionInsertIntoWord();
        return;
      }
    }

    if (isCmdOrCtrl) {
      if (e.key === "i" || e.key === "I") {
        if (!e.shiftKey && !e.altKey) {
          // If in mathfield without selection, Cmd+I triggers Insert into Word!
          e.preventDefault();
          actionInsertIntoWord();
        }
      } else if (e.key === "c" || e.key === "C") {
        if (!e.shiftKey && !e.altKey) {
          e.preventDefault();
          actionCopyPNG();
        }
      } else if (e.key === "t" || e.key === "T") {
        if (e.shiftKey) {
          e.preventDefault();
          insertKhmerText();
        }
      } else if (e.key === "f" || e.key === "F") {
        e.preventDefault();
        insertLatex("\\frac{#?}{#0}");
      } else if (e.key === "r" || e.key === "R") {
        e.preventDefault();
        if (e.shiftKey) {
          insertLatex("\\sqrt[#0]{#?}");
        } else {
          insertLatex("\\sqrt{#?}");
        }
      } else if (e.key === "h" || e.key === "H") {
        e.preventDefault();
        insertLatex("^{#?}");
      } else if (e.key === "l" || e.key === "L") {
        e.preventDefault();
        insertLatex("_{#?}");
      } else if (e.key === "j" || e.key === "J") {
        e.preventDefault();
        insertLatex("_{#0}^{#?}");
      }
    }
  }, true);
}

// ============================================================================
// 6. MICROSOFT WORD DIRECT INSERTION & BASELINE ALIGNMENT
// ============================================================================

/**
 * Calculates ratio depth/height for equation baseline alignment
 */
function calculateBaselineRatio(latex) {
  // Check if equation contains deep characters or fractions/integrals
  if (latex.includes("\\frac") || latex.includes("\\int") || latex.includes("\\sum")) {
    return 0.25;
  }
  if (latex.includes("_") || latex.includes("g") || latex.includes("y") || latex.includes("p") || latex.includes("q")) {
    return 0.18;
  }
  return 0.12;
}

/**
 * Helper to generate crisp transparent equation image DataURL
 */
async function generateEquationImageDataUrl() {
  const latex = mf.getValue("latex") || "x=0";
  const tempDiv = document.createElement("div");
  tempDiv.style.position = "absolute";
  tempDiv.style.left = "-9999px";
  tempDiv.style.top = "-9999px";
  tempDiv.style.padding = "14px 20px";
  tempDiv.style.fontSize = "32px";
  tempDiv.style.background = "transparent";
  document.body.appendChild(tempDiv);

  if (window.katex) {
    katex.render(latex, tempDiv, { displayMode: true, throwOnError: false });
  } else {
    tempDiv.innerText = latex;
  }

  const canvas = await html2canvas(tempDiv, {
    backgroundColor: null,
    scale: 3.0,
    logging: false
  });

  document.body.removeChild(tempDiv);
  return canvas.toDataURL("image/png");
}

/**
 * Toggle TeX: Extract selected equation or LaTeX from Microsoft Word into MathType
 */
function actionToggleTeX() {
  showStatus(currentLang === 'km' ? "⚡ កំពុងទាញយកសមីការពី Word..." : "⚡ Reading selected equation from Word...", false);
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({ type: "toggleTeX" });
  } else {
    showStatus("មុខងារនេះដំណើរការតែក្នុង Native App ប៉ុណ្ណោះ!", false);
  }
}

/**
 * Called by Native App when LaTeX is extracted from Word selection
 */
window.loadLatexFromWord = function(latex) {
  if (!latex || latex.trim() === "") {
    showStatus(currentLang === 'km' ? "សូមជ្រើសរើស (Select) សមីការក្នុង Word ជាមុនសិន!" : "Please select an equation in Word first!", false);
    return;
  }

  let clean = latex.trim();
  // Strip delimiters $...$ or $$...$$ or \[...\] or \(...\)
  if (clean.startsWith("$$") && clean.endsWith("$$")) {
    clean = clean.substring(2, clean.length - 2).trim();
  } else if (clean.startsWith("$") && clean.endsWith("$")) {
    clean = clean.substring(1, clean.length - 1).trim();
  } else if (clean.startsWith("\\[") && clean.endsWith("\\]")) {
    clean = clean.substring(2, clean.length - 2).trim();
  } else if (clean.startsWith("\\(") && clean.endsWith("\\)")) {
    clean = clean.substring(2, clean.length - 2).trim();
  }

  if (mf) {
    mf.setValue(clean);
    mf.focus();
  }
  showStatus(currentLang === 'km' ? "✓ បានបំប្លែងសមីការពី Word មក Mathtype-kh រួចរាល់!" : "✓ Equation loaded from Word into Mathtype-kh!", true);
};

/**
 * Launches Microsoft Word application directly
 */
function actionOpenWord() {
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({ type: "openWord" });
  }
  showStatus(currentLang === 'km' ? "✓ កំពុងបើក Microsoft Word..." : "✓ Opening Microsoft Word...", true);
}

let isInsertingToWord = false;

/**
 * Direct One-Click Insert Into Word (Automates Microsoft Word via AppleScript)
 */
async function actionInsertIntoWord() {
  if (isInsertingToWord) return;
  isInsertingToWord = true;
  try {
    showStatus(currentLang === 'km' ? "⚡ កំពុងដំណើរការ LaTeX Kernel និងបញ្ចូលទៅ Word..." : "⚡ Running LaTeX Kernel & Inserting into Word...", false);
    const latex = mf.getValue("latex");
    if (!latex || latex.trim() === "") {
      showStatus(currentLang === 'km' ? "សូមបញ្ចូលសមីការជាមុនសិន!" : "Please enter an equation first!", true);
      isInsertingToWord = false;
      return;
    }

    saveToHistory(latex);

    const dataUrl = await generateEquationImageDataUrl();
    const ratio = calculateBaselineRatio(latex);

    // If running in Native macOS App (C++ / Objective-C)
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        type: "compileAndInsertWord",
        latex: latex,
        fontSize: currentEquationSize,
        fallbackData: dataUrl,
        ratio: ratio
      });
    } else {
      // Browser fallback: Copy to clipboard and prompt
      await actionCopyPNG();
      showStatus("បានចម្លង! សូមចុច ⌘V ក្នុង Word", true);
    }
  } catch (err) {
    showStatus("កំហុសក្នុងការបញ្ចូល៖ " + err.message);
  } finally {
    setTimeout(() => {
      isInsertingToWord = false;
    }, 1000);
  }
}

/**
 * Copy to Word (Puts crisp Image + MathML + LaTeX on macOS NSPasteboard)
 */
async function actionCopyPNG() {
  try {
    showStatus(currentLang === 'km' ? "⚡ កំពុងចងក្រងសមីការតាម LaTeX Kernel..." : "⚡ Compiling with LaTeX Kernel...", false);
    const latex = mf.getValue("latex") || "x=0";
    saveToHistory(latex);
    const dataUrl = await generateEquationImageDataUrl();
    const ratio = calculateBaselineRatio(latex);

    // Native Cocoa app bridge
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        type: "compileAndCopyWord",
        latex: latex,
        fontSize: currentEquationSize,
        fallbackData: dataUrl,
        ratio: ratio
      });
      showStatus(currentLang === 'km' ? "✓ បានចងក្រង LaTeX 300 DPI រួចចម្លងទៅ Clipboard!" : "✓ LaTeX 300 DPI Copied to Clipboard!", true);
      return;
    }

    // Web Browser fallback
    const res = await fetch(dataUrl);
    const blob = await res.blob();
    await navigator.clipboard.write([
      new ClipboardItem({ "image/png": blob })
    ]);
    showStatus(i18n[currentLang].statusCopied, true);
  } catch (err) {
    showStatus("Export error: " + err.message);
  }
}

/**
 * Copy LaTeX
 */
async function actionCopyLaTeX() {
  const latex = mf.getValue("latex");
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({
      type: "copyLaTeX",
      data: latex
    });
  }
  await navigator.clipboard.writeText(latex);
  showStatus("✓ Copied LaTeX: " + latex, true);
}

function actionClear() {
  mf.setValue("");
  mf.focus();
  showStatus("Canvas cleared");
}

function actionNew() {
  actionClear();
}

function actionUndo() {
  mf.executeCommand("undo");
}

function actionRedo() {
  mf.executeCommand("redo");
}

function actionCut() {
  actionCopyPNG();
  actionClear();
}

function actionCopy() {
  actionCopyPNG();
}

function actionPaste() {
  navigator.clipboard.readText().then(text => {
    insertLatex(text);
  });
}

function actionSelectAll() {
  mf.executeCommand("selectAll");
}

function actionSavePNG() {
  actionCopyPNG();
}

function actionSaveLaTeX() {
  actionCopyLaTeX();
}

// ============================================================================
// 7. VIEW, STYLE, MODALS
// ============================================================================

function setZoom(factor) {
  currentZoom = factor;
  document.getElementById("canvasWrapper").style.transform = `scale(${factor})`;
  document.getElementById("canvasWrapper").style.transformOrigin = "top left";
  const select = document.getElementById("zoomSelect");
  if (select) select.value = factor.toFixed(1);
  showStatus(`Zoom: ${Math.round(factor * 100)}%`);
}

function toggleTabs() {
  const container = document.getElementById("tabbedBarContainer");
  container.style.display = container.style.display === "none" ? "block" : "none";
}

function formatAlign(align) {
  mf.style.textAlign = align === "relation" ? "left" : align;
  showStatus(`Alignment: ${align}`);
}

function setStyle(styleName) {
  if (styleName === "text") {
    mf.executeCommand(["insert", "\\text{#?}"]);
  } else if (styleName === "function") {
    mf.executeCommand(["insert", "\\operatorname{#?}"]);
  } else {
    showStatus(`Style: ${styleName}`);
  }
}

function setFontSize(sizeName) {
  const sizeMap = {
    full: "24px",
    subscript: "18px",
    subsub: "14px",
    symbol: "32px"
  };
  mf.style.fontSize = sizeMap[sizeName] || "24px";
}

function showStatus(msg, isSuccess = false) {
  const el = document.getElementById("statusMessage");
  const dot = document.querySelector(".status-dot");
  if (!el) return;
  el.innerText = msg;
  if (isSuccess) {
    el.classList.add("success");
    if (dot) dot.classList.add("pulse");
    setTimeout(() => {
      el.classList.remove("success");
      if (dot) dot.classList.remove("pulse");
      el.innerText = i18n[currentLang].statusReady;
    }, 4500);
  }
}

function showAboutModal() {
  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");
  if (footer) {
    footer.innerHTML = '<button class="action-btn insert-word-action" style="padding: 0 20px;" onclick="closeModal()">OK</button>';
  }
  title.innerText = currentLang === 'km' ? "អំពី Mathtype-kh" : "About Mathtype-kh";
  body.innerHTML = `
    <div style="text-align: center; margin-bottom: 16px;">
      <img src="./assets/icons/MT_ICO.png" width="56" height="56" style="margin-bottom: 8px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.12);">
      <h2 style="font-size: 18px; margin: 0; color: #111; font-weight: 700;">Mathtype-kh</h2>
      <p style="font-size: 13.5px; color: #107c41; font-weight: 600; margin: 5px 0 0 0;">👨‍💻 អ្នកធ្វើ (Author): K.Reaksmey</p>
      <p style="font-size: 11.5px; color: #64748b; margin: 4px 0 0 0;">Version 7.4.4 (Native 64-bit Khmer Edition)</p>
    </div>
    <p style="font-size: 12.5px; line-height: 1.6; color: #334155; margin: 0 0 10px 0;">
      ${currentLang === 'km' 
        ? "កម្មវិធី <b>Mathtype-kh</b> ត្រូវបានបង្កើត និងអភិវឌ្ឍដោយ <b>K.Reaksmey</b> សម្រាប់សម្រួលដល់ការសរសេរសមីការគណិតវិទ្យា វិទ្យាសាស្ត្រ និងការបញ្ចូលរូបមន្តទៅក្នុង Microsoft Word ដោយស្វ័យប្រវត្តិតាមរយៈប្រព័ន្ធកូដកម្រិតខ្ពស់ និងតម្រឹមបន្ទាត់យ៉ាងស្រស់ស្អាត។" 
        : "<b>Mathtype-kh</b> is developed by <b>K.Reaksmey</b> for fast and intuitive mathematical equation editing with automated 1-click Microsoft Word integration and baseline alignment."}
    </p>
    <ul style="margin: 10px 0 12px 20px; font-size: 12px; color: #475569; line-height: 1.8;">
      <li><b>កំណែប្រែ (Version)៖</b> <span style="color: #2563eb; font-weight: 600;">v7.4.4</span></li>
      <li><b>អ្នកធ្វើ (Author / Creator)៖</b> <span style="color: #107c41; font-weight: 600;">K.Reaksmey</span></li>
      <li><b>ភាសាសរសេរ (Core):</b> C++ & Objective-C (Apple Cocoa / AppKit)</li>
      <li><b>ប្រព័ន្ធគណនា (Engine):</b> High-Resolution TeX Engine (300 DPI)</li>
      <li><b>ការបញ្ចូល Word:</b> 1-Click Auto Insert into Word (⌘I / Enter)</li>
      <li><b>តម្រឹមបន្ទាត់ (Baseline Alignment):</b> ស្វ័យប្រវត្តិ (Depth Ratio)</li>
      <li><b>ភាសាគាំទ្រ (Languages):</b> ភាសាខ្មែរ 🇰🇭 & English 🇺🇸</li>
    </ul>
    <div style="text-align: center; margin-top: 14px; padding-top: 10px; border-top: 1px solid #e2e8f0; font-size: 11px; color: #94a3b8;">
      © 2026 Mathtype-kh • Created by K.Reaksmey
    </div>
  `;
  document.getElementById("modalOverlay").classList.remove("hidden");
}

function showHelpModal() {
  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");
  if (footer) {
    footer.innerHTML = '<button class="action-btn primary-action" onclick="closeModal()">OK</button>';
  }
  title.innerText = "របៀបប្រើប្រាស់ជាមួយ Microsoft Word";
  body.innerHTML = `
    <div style="font-size: 13px; line-height: 1.6;">
      <h4 style="margin: 8px 0 4px 0; color: #107c41;">⚡ មុខងារ "បញ្ចូលទៅ Word" (One-Click Insert)៖</h4>
      <p>គ្រាន់តែចុចលើប៊ូតុងពណ៌បៃតង <b>"បញ្ចូលទៅ Word"</b> កម្មវិធីនឹងបញ្ជូនរូបមន្តទៅបិទត្រង់កន្លែងទស្សន៍ទ្រនិចក្នុង Microsoft Word ដោយស្វ័យប្រវត្តិ ព្រមទាំងតម្រឹមជួរបន្ទាត់ (Baseline Alignment) យ៉ាងស្រស់ស្អាត!</p>
      <hr style="margin: 12px 0; border: none; border-top: 1px solid #ddd;">
      <h4 style="margin: 8px 0 4px 0;">គ្រាប់ចុចកាត់ (Keyboard Shortcuts)៖</h4>
      <table style="width: 100%; border-collapse: collapse; font-size: 12px;">
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + I</td><td>បញ្ចូលទៅ Word ផ្ទាល់ (Insert into Word)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌥ + \\ ឬ ⌥ + T</td><td>Toggle TeX (ស្រង់សមីការចេញពី Word មកកែប្រែ)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + C</td><td>ចម្លងទៅ Word (Copy to Word)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + F</td><td>ប្រភាគបញ្ឈរ (Fraction)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + R</td><td>ឬសការេ (Square Root)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + H</td><td>ស្វ័យគុណ (Exponent)</td></tr>
        <tr><td style="padding: 4px; font-family: monospace;">⌘ + L</td><td>សន្ទស្សន៍ (Subscript)</td></tr>
      </table>
    </div>
  `;
  document.getElementById("modalOverlay").classList.remove("hidden");
}

function showLaTeXConfigModal() {
  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");

  title.innerHTML = currentLang === 'km' ? "⚙️ កំណត់ផ្លូវ LaTeX Path (Configure LaTeX Engine)" : "⚙️ Configure LaTeX Path";

  const savedPath = localStorage.getItem("mathtype_texbin_path") || "/Library/TeX/texbin";

  body.innerHTML = `
    <div class="tex-config-container">
      <p style="margin: 0; font-size: 12.5px; color: #475569;">
        ${currentLang === 'km' 
          ? "Mathtype-kh ប្រើប្រាស់ LaTeX Kernel ដើម្បីបង្កើតសមីការច្បាស់កម្រិត 300 DPI ចូលក្នុង Microsoft Word។ សូមពិនិត្យ ឬកំណត់ទីតាំងថត (Binary Directory) របស់ TeX:"
          : "Mathtype-kh uses the LaTeX Kernel to generate crystal clear 300 DPI equations into Microsoft Word. Please check or configure your TeX binary directory:"}
      </p>

      <div class="tex-input-group">
        <input type="text" id="texPathInput" class="tex-input" value="${savedPath}" placeholder="/Library/TeX/texbin" />
        <button class="tex-btn" onclick="testCustomTeXPath()">${currentLang === 'km' ? "🔍 ពិនិត្យ" : "🔍 Check"}</button>
      </div>

      <div>
        <span style="font-size: 11.5px; color: #64748b; font-weight: 500;">${currentLang === 'km' ? "ផ្លូវពេញនិយម (Presets)៖" : "Common Presets:"}</span>
        <div class="tex-presets">
          <button class="tex-preset-btn" onclick="setTeXInputPath('/Library/TeX/texbin')">MacTeX (/Library/TeX/texbin)</button>
          <button class="tex-preset-btn" onclick="setTeXInputPath('/opt/homebrew/bin')">Homebrew (/opt/homebrew/bin)</button>
          <button class="tex-preset-btn" onclick="setTeXInputPath('/usr/local/bin')">Intel (/usr/local/bin)</button>
        </div>
      </div>

      <div class="tex-status-box" id="texStatusBox">
        <div class="tex-status-item">
          <span>LaTeX Compiler (<code>latex</code>):</span>
          <span id="badgeLatex" class="tex-badge">កំពុងពិនិត្យ...</span>
        </div>
        <div class="tex-status-item">
          <span>DVI to PNG (<code>dvipng</code>):</span>
          <span id="badgeDvipng" class="tex-badge">កំពុងពិនិត្យ...</span>
        </div>
        <div class="tex-status-item">
          <span>Baseline Analyzer (<code>dvisvgm</code>):</span>
          <span id="badgeDvisvgm" class="tex-badge">កំពុងពិនិត្យ...</span>
        </div>
      </div>
      <div id="texStatusNote" style="font-size: 12px; color: #64748b;"></div>
    </div>
  `;

  if (footer) {
    footer.innerHTML = `
      <button class="tex-btn" onclick="closeModal()" style="margin-right: 8px;">${currentLang === 'km' ? "បោះបង់" : "Cancel"}</button>
      <button class="tex-btn primary" onclick="saveCustomTeXPath()">${currentLang === 'km' ? "💾 រក្សាទុក & ប្រើប្រាស់" : "💾 Save & Apply"}</button>
    `;
  }

  document.getElementById("modalOverlay").classList.remove("hidden");

  // Automatically test current path
  testCustomTeXPath();
}

function setTeXInputPath(path) {
  const input = document.getElementById("texPathInput");
  if (input) {
    input.value = path;
    testCustomTeXPath();
  }
}

function testCustomTeXPath() {
  const input = document.getElementById("texPathInput");
  const path = input ? input.value.trim() : "/Library/TeX/texbin";

  const badgeLatex = document.getElementById("badgeLatex");
  const badgeDvipng = document.getElementById("badgeDvipng");
  const badgeDvisvgm = document.getElementById("badgeDvisvgm");
  if (badgeLatex) { badgeLatex.className = "tex-badge"; badgeLatex.innerText = "..."; }
  if (badgeDvipng) { badgeDvipng.className = "tex-badge"; badgeDvipng.innerText = "..."; }
  if (badgeDvisvgm) { badgeDvisvgm.className = "tex-badge"; badgeDvisvgm.innerText = "..."; }

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({
      type: "checkTeXPath",
      path: path
    });
  }
}

function updateLaTeXConfigStatus(data) {
  const badgeLatex = document.getElementById("badgeLatex");
  const badgeDvipng = document.getElementById("badgeDvipng");
  const badgeDvisvgm = document.getElementById("badgeDvisvgm");
  const note = document.getElementById("texStatusNote");

  if (badgeLatex) {
    badgeLatex.className = "tex-badge " + (data.latex ? "success" : "error");
    badgeLatex.innerText = data.latex ? "✓ មាន (Found)" : "✗ រកមិនឃើញ (Missing)";
  }
  if (badgeDvipng) {
    badgeDvipng.className = "tex-badge " + (data.dvipng ? "success" : "error");
    badgeDvipng.innerText = data.dvipng ? "✓ មាន (Found)" : "✗ រកមិនឃើញ (Missing)";
  }
  if (badgeDvisvgm) {
    badgeDvisvgm.className = "tex-badge " + (data.dvisvgm ? "success" : "error");
    badgeDvisvgm.innerText = data.dvisvgm ? "✓ មាន (Found)" : "✗ រកមិនឃើញ (Missing)";
  }

  if (note) {
    if (data.latex && data.dvipng) {
      note.innerHTML = `<span style="color: #107c41; font-weight: 500;">✓ ផ្លូវ LaTeX ត្រឹមត្រូវ និងរួចរាល់សម្រាប់ការបង្កើតសមីការ!</span>`;
    } else {
      note.innerHTML = `<span style="color: #c53030; font-weight: 500;">⚠ មិនអាចរកឃើញ latex/dvipng ក្នុងថតនេះទេ។ សូមជ្រើសរើសថតផ្សេង ឬដំឡើង MacTeX / BasicTeX។</span>`;
    }
  }
}

function saveCustomTeXPath() {
  const input = document.getElementById("texPathInput");
  const path = input ? input.value.trim() : "/Library/TeX/texbin";

  localStorage.setItem("mathtype_texbin_path", path);

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({
      type: "setTeXPath",
      path: path
    });
  }

  closeModal();
  showStatus(currentLang === 'km' ? `✓ បានកំណត់ផ្លូវ LaTeX៖ ${path}` : `✓ LaTeX Path saved: ${path}`, true);
}

const DEFAULT_PREAMBLE = `\\usepackage{lmodern}
\\usepackage{amsmath,amssymb,amsfonts}
\\usepackage{xcolor}
\\nopagecolor`;

function showLaTeXPreambleModal() {
  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");

  title.innerHTML = currentLang === 'km' ? "📜 កំណត់ LaTeX Preamble (Packages & Macros)" : "📜 Configure LaTeX Preamble";

  const savedPreamble = localStorage.getItem("mathtype_custom_preamble") || DEFAULT_PREAMBLE;

  body.innerHTML = `
    <div class="tex-config-container">
      <p style="margin: 0; font-size: 12.5px; color: #475569;">
        ${currentLang === 'km' 
          ? "បន្ថែម ឬកែប្រែកញ្ចប់ Packages (ឧ. amsmath, physics, siunitx, bm) និង Macro Commands (\\newcommand) សម្រាប់ប្រើប្រាស់ក្នុងដំណើរការបង្កើតសមីការ 300 DPI៖"
          : "Add or edit LaTeX packages (e.g. amsmath, physics, siunitx, bm) and custom macros (\\newcommand) used during 300 DPI equation rendering:"}
      </p>

      <textarea id="texPreambleInput" class="tex-textarea" placeholder="${DEFAULT_PREAMBLE}">${savedPreamble}</textarea>

      <div>
        <span style="font-size: 11.5px; color: #64748b; font-weight: 500;">${currentLang === 'km' ? "កញ្ចប់ពេញនិយម (Quick Insert)៖" : "Quick Insert Packages:"}</span>
        <div class="tex-presets" style="margin-top: 6px;">
          <button class="tex-preset-btn" onclick="insertPreamblePackage('\\\\usepackage{physics}')">+ physics</button>
          <button class="tex-preset-btn" onclick="insertPreamblePackage('\\\\usepackage{siunitx}')">+ siunitx</button>
          <button class="tex-preset-btn" onclick="insertPreamblePackage('\\\\usepackage{bm}')">+ bm (Bold Math)</button>
          <button class="tex-preset-btn" onclick="insertPreamblePackage('\\\\usepackage{cancel}')">+ cancel</button>
          <button class="tex-preset-btn" onclick="insertPreamblePackage('\\\\usepackage{mathtools}')">+ mathtools</button>
        </div>
      </div>

      <div style="font-size: 11.5px; color: #64748b;">
        💡 <b>${currentLang === 'km' ? "ចំណាំ" : "Note"}:</b> ${currentLang === 'km' ? "រាល់កញ្ចប់ដែលអ្នកបន្ថែមនៅទីនេះ នឹងត្រូវបានប្រើប្រាស់ដោយស្វ័យប្រវត្តិនៅពេល compile សមីការ និងបញ្ជូនទៅកាន់ Microsoft Word។" : "All packages and macros defined here will be automatically applied when compiling equations for Microsoft Word."}
      </div>
    </div>
  `;

  if (footer) {
    footer.innerHTML = `
      <button class="tex-btn" onclick="resetPreambleDefault()" style="margin-right: auto;">${currentLang === 'km' ? "🔄 យកលំនាំដើមវិញ" : "🔄 Reset Default"}</button>
      <button class="tex-btn" onclick="closeModal()" style="margin-right: 8px;">${currentLang === 'km' ? "បោះបង់" : "Cancel"}</button>
      <button class="tex-btn primary" onclick="saveCustomPreamble()">${currentLang === 'km' ? "💾 រក្សាទុក & ប្រើប្រាស់" : "💾 Save & Apply"}</button>
    `;
  }

  document.getElementById("modalOverlay").classList.remove("hidden");

  // Query native app for preamble if available
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({ type: "getPreamble" });
  }
}

function insertPreamblePackage(pkgCode) {
  const textarea = document.getElementById("texPreambleInput");
  if (!textarea) return;
  if (!textarea.value.includes(pkgCode)) {
    textarea.value = textarea.value.trim() + "\n" + pkgCode;
  }
  textarea.focus();
}

function resetPreambleDefault() {
  const textarea = document.getElementById("texPreambleInput");
  if (textarea) {
    textarea.value = DEFAULT_PREAMBLE;
  }
}

function updateLaTeXPreamble(preamble) {
  const textarea = document.getElementById("texPreambleInput");
  if (textarea && preamble && preamble.trim().length > 0) {
    textarea.value = preamble;
    localStorage.setItem("mathtype_custom_preamble", preamble);
  }
}

function saveCustomPreamble() {
  const textarea = document.getElementById("texPreambleInput");
  const preamble = textarea ? textarea.value.trim() : DEFAULT_PREAMBLE;

  localStorage.setItem("mathtype_custom_preamble", preamble);

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({
      type: "setPreamble",
      preamble: preamble
    });
  }

  closeModal();
  showStatus(currentLang === 'km' ? "✓ បានរក្សាទុក LaTeX Preamble រួចរាល់!" : "✓ LaTeX Preamble saved successfully!", true);
}

function closeModal() {
  document.getElementById("modalOverlay").classList.add("hidden");
  const footer = document.getElementById("modalFooter");
  if (footer) {
    footer.innerHTML = '<button class="action-btn primary-action" onclick="closeModal()">OK</button>';
  }
}

// ============================================================================
// 10. ADVANCED FEATURES: KHMER TEXT, HISTORY, FAVORITES, SVG/PDF, UPDATES
// ============================================================================

/**
 * 1. Khmer Text in Math Mode (\text{...})
 */
function insertKhmerText() {
  if (!mf) return;
  insertLatex("\\text{#?}");
  mf.focus();
}

/**
 * 2. Equation History & Favorites Management
 */
function getHistory() {
  try {
    return JSON.parse(localStorage.getItem("mathtype_history") || "[]");
  } catch (e) {
    return [];
  }
}

function saveToHistory(latex) {
  if (!latex || !latex.trim()) return;
  const clean = latex.trim();
  let list = getHistory();
  list = list.filter(item => item.latex !== clean);
  list.unshift({ latex: clean, time: Date.now() });
  if (list.length > 30) list = list.slice(0, 30);
  try {
    localStorage.setItem("mathtype_history", JSON.stringify(list));
  } catch (e) {}
}

function getFavorites() {
  try {
    return JSON.parse(localStorage.getItem("mathtype_favorites") || "[]");
  } catch (e) {
    return [];
  }
}

function toggleFavorite(latex) {
  if (!latex || !latex.trim()) return false;
  const clean = latex.trim();
  let favs = getFavorites();
  const idx = favs.findIndex(item => item.latex === clean);
  let isFav = false;
  if (idx >= 0) {
    favs.splice(idx, 1);
    isFav = false;
  } else {
    favs.unshift({ latex: clean, time: Date.now() });
    isFav = true;
  }
  try {
    localStorage.setItem("mathtype_favorites", JSON.stringify(favs));
  } catch (e) {}
  return isFav;
}

function deleteHistoryItem(index) {
  let list = getHistory();
  list.splice(index, 1);
  try {
    localStorage.setItem("mathtype_history", JSON.stringify(list));
  } catch (e) {}
  openHistoryModal();
}

function clearAllHistory() {
  localStorage.removeItem("mathtype_history");
  openHistoryModal();
}

function deleteFavoriteItem(index) {
  let favs = getFavorites();
  favs.splice(index, 1);
  try {
    localStorage.setItem("mathtype_favorites", JSON.stringify(favs));
  } catch (e) {}
  openFavoritesModal();
}

function useEquationFromList(latex) {
  if (mf) {
    mf.setValue(latex);
    mf.focus();
  }
  closeModal();
  showStatus(currentLang === 'km' ? "✓ បានជ្រើសរើសរូបមន្ត!" : "✓ Loaded equation!", true);
}

function toggleFavoriteFromModal(latex, isHistory) {
  toggleFavorite(latex);
  if (isHistory) {
    openHistoryModal();
  } else {
    openFavoritesModal();
  }
}

function openHistoryModal() {
  const list = getHistory();
  const favs = getFavorites();
  const favSet = new Set(favs.map(f => f.latex));

  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");
  
  title.innerText = currentLang === 'km' ? "🕒 ប្រវត្តិសមីការ (Equation History)" : "🕒 Equation History";
  
  if (list.length === 0) {
    body.innerHTML = `
      <div style="text-align: center; padding: 30px; color: #64748b;">
        <p style="font-size: 15px; margin-bottom: 8px;">📂 ${currentLang === 'km' ? "មិនទាន់មានប្រវត្តិសមីការនៅឡើយទេ" : "No equation history yet"}</p>
        <p style="font-size: 12px;">${currentLang === 'km' ? "សមីការដែលអ្នកបញ្ចូលទៅ Word ឬចម្លង នឹងត្រូវរក្សាទុកនៅទីនេះដោយស្វ័យប្រវត្តិ។" : "Equations you insert into Word or copy will automatically appear here."}</p>
      </div>
    `;
    footer.innerHTML = `<button class="action-btn" onclick="closeModal()">OK</button>`;
  } else {
    let html = `<div class="history-list">`;
    list.forEach((item, idx) => {
      const isFav = favSet.has(item.latex);
      const safeLatex = item.latex.replace(/\\/g, "\\\\").replace(/"/g, "&quot;").replace(/'/g, "\\'");
      html += `
        <div class="history-card">
          <div class="history-eq-preview" id="hist_preview_${idx}" onclick="useEquationFromList('${safeLatex}')"></div>
          <div class="history-actions">
            <button class="btn-star ${isFav ? 'active' : ''}" title="${isFav ? 'Remove Favorite' : 'Add to Favorites'}" onclick="toggleFavoriteFromModal('${safeLatex}', true)">★</button>
            <button class="action-btn insert-word-action" style="padding: 2px 10px; font-size: 11.5px;" onclick="useEquationFromList('${safeLatex}')">${currentLang === 'km' ? "ប្រើ" : "Use"}</button>
            <button class="btn-delete-item" title="Delete" onclick="deleteHistoryItem(${idx})">✕</button>
          </div>
        </div>
      `;
    });
    html += `</div>`;
    body.innerHTML = html;
    footer.innerHTML = `
      <div style="display: flex; justify-content: space-between; width: 100%;">
        <button class="action-btn danger-hover-btn" onclick="clearAllHistory()">${currentLang === 'km' ? "សម្អាតប្រវត្តិទាំងអស់" : "Clear All History"}</button>
        <button class="action-btn" onclick="closeModal()">${currentLang === 'km' ? "បិទ" : "Close"}</button>
      </div>
    `;

    setTimeout(() => {
      list.forEach((item, idx) => {
        const el = document.getElementById(`hist_preview_${idx}`);
        if (el) {
          try {
            katex.render(item.latex, el, { throwOnError: false, displayMode: false });
          } catch(e) {
            el.innerText = item.latex;
          }
        }
      });
    }, 50);
  }

  document.getElementById("modalOverlay").classList.remove("hidden");
}

function openFavoritesModal() {
  const favs = getFavorites();

  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");
  
  title.innerText = currentLang === 'km' ? "⭐ រូបមន្តសំណព្វ (Favorites)" : "⭐ Favorite Formulas";
  
  if (favs.length === 0) {
    body.innerHTML = `
      <div style="text-align: center; padding: 30px; color: #64748b;">
        <p style="font-size: 15px; margin-bottom: 8px;">⭐ ${currentLang === 'km' ? "មិនទាន់មានរូបមន្តសំណព្វនៅឡើយទេ" : "No favorite equations yet"}</p>
        <p style="font-size: 12px;">${currentLang === 'km' ? "អ្នកអាចចុចផ្កាយ ★ ក្នុងបញ្ជីប្រវត្តិ ដើម្បីរក្សាទុករូបមន្តដែលប្រើញឹកញាប់។" : "Click the star icon ★ on any equation in History to bookmark it here."}</p>
      </div>
    `;
    footer.innerHTML = `<button class="action-btn" onclick="closeModal()">OK</button>`;
  } else {
    let html = `<div class="history-list">`;
    favs.forEach((item, idx) => {
      const safeLatex = item.latex.replace(/\\/g, "\\\\").replace(/"/g, "&quot;").replace(/'/g, "\\'");
      html += `
        <div class="history-card">
          <div class="history-eq-preview" id="fav_preview_${idx}" onclick="useEquationFromList('${safeLatex}')"></div>
          <div class="history-actions">
            <button class="action-btn insert-word-action" style="padding: 2px 10px; font-size: 11.5px;" onclick="useEquationFromList('${safeLatex}')">${currentLang === 'km' ? "ប្រើ" : "Use"}</button>
            <button class="btn-delete-item" title="Delete" onclick="deleteFavoriteItem(${idx})">✕</button>
          </div>
        </div>
      `;
    });
    html += `</div>`;
    body.innerHTML = html;
    footer.innerHTML = `<button class="action-btn" onclick="closeModal()">${currentLang === 'km' ? "បិទ" : "Close"}</button>`;

    setTimeout(() => {
      favs.forEach((item, idx) => {
        const el = document.getElementById(`fav_preview_${idx}`);
        if (el) {
          try {
            katex.render(item.latex, el, { throwOnError: false, displayMode: false });
          } catch(e) {
            el.innerText = item.latex;
          }
        }
      });
    }, 50);
  }

  document.getElementById("modalOverlay").classList.remove("hidden");
}

/**
 * 3. Vector SVG & PDF Export
 */
async function actionSaveSVG() {
  try {
    showStatus(currentLang === 'km' ? "⚡ កំពុងរៀបចំរូបភាព Vector SVG..." : "⚡ Preparing Vector SVG...", false);
    const latex = mf.getValue("latex");
    if (!latex || !latex.trim()) {
      showStatus(currentLang === 'km' ? "សូមបញ្ចូលសមីការជាមុនសិន!" : "Please enter an equation first!", true);
      return;
    }
    saveToHistory(latex);

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        type: "saveSVG",
        latex: latex,
        fontSize: currentEquationSize
      });
    } else {
      let svgMarkup = "";
      try {
        const mathML = mf.getValue("math-ml");
        const blob = new Blob([mathML], { type: "image/svg+xml;charset=utf-8" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "equation.svg";
        a.click();
        URL.revokeObjectURL(url);
      } catch (e) {
        showStatus("SVG Export Error: " + e.message);
      }
    }
  } catch (err) {
    showStatus("SVG Error: " + err.message);
  }
}

async function actionSavePDF() {
  try {
    showStatus(currentLang === 'km' ? "⚡ កំពុងរៀបចំឯកសារ Vector PDF..." : "⚡ Preparing Vector PDF...", false);
    const latex = mf.getValue("latex");
    if (!latex || !latex.trim()) {
      showStatus(currentLang === 'km' ? "សូមបញ្ចូលសមីការជាមុនសិន!" : "Please enter an equation first!", true);
      return;
    }
    saveToHistory(latex);

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        type: "savePDF",
        latex: latex,
        fontSize: currentEquationSize
      });
    } else {
      window.print();
    }
  } catch (err) {
    showStatus("PDF Error: " + err.message);
  }
}

/**
 * 4. GitHub Releases Auto-Update Checker
 */
async function actionCheckUpdates() {
  const title = document.getElementById("modalTitle");
  const body = document.getElementById("modalBody");
  const footer = document.getElementById("modalFooter");
  
  title.innerText = currentLang === 'km' ? "🔄 ពិនិត្យមើលកំណែថ្មី" : "🔄 Check for Updates";
  body.innerHTML = `
    <div style="text-align: center; padding: 25px;">
      <p style="font-size: 14px; color: #3b82f6;">⚡ ${currentLang === 'km' ? "កំពុងពិនិត្យកំណែថ្មីពី GitHub..." : "Checking for updates from GitHub..."}</p>
    </div>
  `;
  footer.innerHTML = `<button class="action-btn" onclick="closeModal()">Cancel</button>`;
  document.getElementById("modalOverlay").classList.remove("hidden");

  try {
    const currentVersion = "7.4.4";
    const res = await fetch("https://api.github.com/repos/Krotreaksmey2200/Mathtype_kh/releases/latest");
    if (!res.ok) throw new Error("Could not fetch release info");
    const data = await res.json();
    const latestTag = data.tag_name || "";
    const cleanLatest = latestTag.replace(/^v/, "");

    const isNewer = cleanLatest.localeCompare(currentVersion, undefined, { numeric: true, sensitivity: 'base' }) > 0;

    if (isNewer) {
      body.innerHTML = `
        <div style="text-align: center; margin-bottom: 12px;">
          <h3 style="color: #107c41; font-size: 16px;">🎉 ${currentLang === 'km' ? "មានកំណែថ្មីអាចទាញយកបាន!" : "New Update Available!"}</h3>
          <p style="font-size: 13px; color: #475569; margin: 4px 0 10px 0;">
            ${currentLang === 'km' ? "កំណែបច្ចុប្បន្ន" : "Current"}: <b>v${currentVersion}</b> ➔ ${currentLang === 'km' ? "កំណែថ្មី" : "Latest"}: <b style="color: #2563eb;">${latestTag}</b>
          </p>
        </div>
        <div class="update-box">
          <p style="font-size: 12px; font-weight: 600; margin-bottom: 6px; color: #15803d;">📝 ${currentLang === 'km' ? "កំណត់ត្រានៃការផ្លាស់ប្តូរ (Changelog)" : "Release Notes"}:</p>
          <div style="font-size: 11.5px; line-height: 1.5; color: #334155; max-height: 140px; overflow-y: auto; white-space: pre-wrap;">${data.body || "Bug fixes and improvements."}</div>
        </div>
      `;
      footer.innerHTML = `
        <div style="display: flex; justify-content: flex-end; gap: 8px; width: 100%;">
          <button class="action-btn" onclick="closeModal()">${currentLang === 'km' ? "ពេលក្រោយ" : "Later"}</button>
          <button class="action-btn insert-word-action" onclick="openExternalUrl('${data.html_url}'); closeModal();">⬇️ ${currentLang === 'km' ? "ទាញយកកំណែថ្មី" : "Download Update"}</button>
        </div>
      `;
    } else {
      body.innerHTML = `
        <div style="text-align: center; padding: 25px;">
          <div style="font-size: 36px; margin-bottom: 8px;">✓</div>
          <h3 style="color: #107c41; font-size: 16px; margin-bottom: 6px;">${currentLang === 'km' ? "លោកអ្នកកំពុងប្រើប្រាស់កំណែថ្មីចុងក្រោយបង្អស់!" : "You are up to date!"}</h3>
          <p style="font-size: 13px; color: #64748b;">Mathtype-kh v${currentVersion} ${currentLang === 'km' ? "ជាកំណែចុងក្រោយបំផុតលើ GitHub រួចរាល់ហើយ។" : "is the latest version available."}</p>
        </div>
      `;
      footer.innerHTML = `<button class="action-btn insert-word-action" onclick="closeModal()">OK</button>`;
    }
  } catch (err) {
    body.innerHTML = `
      <div style="text-align: center; padding: 20px; color: #64748b;">
        <p style="color: #ef4444; font-size: 14px; margin-bottom: 6px;">⚠️ ${currentLang === 'km' ? "មិនអាចតភ្ជាប់ទៅកាន់ GitHub បានទេ" : "Could not connect to GitHub"}</p>
        <p style="font-size: 12px;">${err.message}</p>
      </div>
    `;
    footer.innerHTML = `<button class="action-btn" onclick="closeModal()">OK</button>`;
  }
}

function openExternalUrl(url) {
  if (!url) return;
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
    window.webkit.messageHandlers.nativeApp.postMessage({ type: "openURL", url: url });
  } else {
    window.open(url, "_blank");
  }
}


