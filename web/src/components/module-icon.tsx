"use client";

import Image from "next/image";

interface ModuleIconProps {
  iconPath: string | null;
  displayName: string;
}

export function ModuleIcon({ iconPath, displayName }: ModuleIconProps) {
  if (!iconPath) {
    return (
      <span className="text-2xl font-bold" style={{ color: "#d97706" }}>
        {displayName.charAt(0).toUpperCase()}
      </span>
    );
  }

  return (
    <Image
      src={iconPath}
      alt={displayName}
      width={36}
      height={36}
      className="w-9 h-9"
      onError={(e) => {
        (e.target as HTMLImageElement).style.display = "none";
      }}
    />
  );
}
