export default function Loading() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="relative">
        {/* Animated spinner with Anthropic styling */}
        <div className="relative w-16 h-16">
          <div className="absolute inset-0 rounded-full" style={{ border: "2px solid #e0e0d8" }} />
          <div
            className="absolute inset-0 rounded-full animate-spin"
            style={{
              border: "2px solid transparent",
              borderTopColor: "#d97706",
              borderRightColor: "#d97706",
            }}
          />

          {/* Center icon */}
          <div
            className="absolute inset-0 flex items-center justify-center"
            style={{ padding: "16px" }}
          >
            <img
              src="/lattice-logo.svg"
              alt="Lattice"
              className="w-8 h-8"
            />
          </div>
        </div>

        {/* Loading text */}
        <div className="mt-8 text-center">
          <p
            className="font-medium text-sm"
            style={{ color: "#666666" }}
          >
            Loading...
          </p>
        </div>
      </div>
    </div>
  );
}
