"use client";

import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium transition-colors",
  {
    variants: {
      variant: {
        default:
          "bg-[#d97706] text-white border border-[#d97706]",
        secondary:
          "bg-[#ebe9e1] text-[#666666] border border-[#e0e0d8]",
        success:
          "bg-emerald-500/10 text-emerald-600 border border-emerald-500/20",
        warning:
          "bg-amber-500/10 text-amber-600 border border-amber-500/20",
        destructive:
          "bg-red-500/10 text-red-600 border border-red-500/20",
        outline:
          "border border-[#d0d0c8] text-[#666666] hover:border-[#c0c0b8] hover:text-[#1a1a1a]",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  );
}

export { Badge, badgeVariants };
