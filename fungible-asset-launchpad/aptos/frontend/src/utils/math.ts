export const onChainToHumanReadable = (value: number, decimal: number) => {
  return (value / Math.pow(10, decimal)).toFixed(decimal);
};

export const humanReadableToOnChain = (value: number, decimal: number) => {
  return value * Math.pow(10, decimal);
};
