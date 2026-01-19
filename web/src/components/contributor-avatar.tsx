"use client";

import { useState } from "react";

interface ContributorAvatarProps {
  githubUsername: string;
  displayName: string;
  size?: "sm" | "md" | "lg";
}

export function ContributorAvatar({
  githubUsername,
  displayName,
  size = "md",
}: ContributorAvatarProps) {
  const [imageError, setImageError] = useState(false);

  const sizeClasses = {
    sm: "h-10 w-10 text-sm",
    md: "h-14 w-14 text-xl",
    lg: "h-24 w-24 text-3xl",
  };

  const sizeClass = sizeClasses[size];

  if (imageError) {
    return (
      <div
        className={`${sizeClass} rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center text-white font-bold`}
      >
        {displayName.charAt(0).toUpperCase()}
      </div>
    );
  }

  return (
    <img
      src={`https://github.com/${githubUsername}.png`}
      alt={displayName}
      className={`${sizeClass} rounded-xl object-cover border border-slate-700`}
      onError={() => setImageError(true)}
    />
  );
}
