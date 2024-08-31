export const dateToSeconds = (date: Date | undefined) => {
  if (!date) return;
  const dateInSeconds = Math.floor(+date / 1000);
  return dateInSeconds;
};

export const APT_DECIMALS = 8;

export const convertAmountFromHumanReadableToOnChain = (value: number, decimal: number) => {
  return value * Math.pow(10, decimal);
};
