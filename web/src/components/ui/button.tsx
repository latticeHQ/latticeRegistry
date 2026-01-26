"use client";

import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default:
          "bg-[#d97706] text-white hover:bg-[#b45309] active:bg-[#92400e]",
        secondary:
          "bg-[#ebe9e1] text-[#1a1a1a] hover:bg-[#ddd9cc] active:bg-[#d0ccc0] border border-[#e0e0d8]",
        outline:
          "border border-[#d0d0c8] bg-transparent text-[#1a1a1a] hover:bg-[#ebe9e1] hover:border-[#c0c0b8] active:bg-[#ddd9cc]",
        ghost:
          "text-[#666666] hover:bg-[#ebe9e1] hover:text-[#1a1a1a] active:bg-[#ddd9cc]",
        link: "text-[#d97706] underline-offset-4 hover:underline hover:text-[#b45309] p-0 h-auto",
        destructive:
          "bg-red-600 text-white hover:bg-red-500 active:bg-red-700",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 px-3 text-xs",
        lg: "h-10 px-5",
        xl: "h-11 px-6",
        icon: "h-9 w-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = "Button";

export { Button, buttonVariants };
