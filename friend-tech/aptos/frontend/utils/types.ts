export type Holding = {
  issuer: `0x${string}`;
  holder: `0x${string}`;
  shares: number;
};

export type Issuer = {
  issuerObjectAddress: `0x${string}`;
  issuerAddress: `0x${string}`;
  username: string;
  totalIssuedShares: number;
};
