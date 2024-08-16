export function clampNumber(num: number, min: number = 0, max: number = 100_000_000): string {
  if (num < min) {
    return `<${min.toString()}`;
  }

  if (num > max) {
    return `>${max.toString()}`;
  }

  return num.toString();
}
