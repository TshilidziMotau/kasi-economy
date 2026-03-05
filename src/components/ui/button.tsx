import { ButtonHTMLAttributes } from 'react';
import { cn } from '@/lib/utils';

export function Button({ className, ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={cn(
        'inline-flex h-11 items-center justify-center rounded-lg bg-green-600 px-4 text-sm font-semibold text-white transition hover:bg-green-700 disabled:cursor-not-allowed disabled:bg-slate-300',
        className
      )}
      {...props}
    />
  );
}
