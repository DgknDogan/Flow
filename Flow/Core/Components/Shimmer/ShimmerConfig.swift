struct ShimmerConfig {
    let height: Double
    let width: Double
    let cornerRadius: Double

    init(height: Double, width: Double = .infinity, cornerRadius: Double = AppRadius.card) {
        self.height = height
        self.width = width
        self.cornerRadius = cornerRadius
    }
}
