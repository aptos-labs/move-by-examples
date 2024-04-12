import {
  getAssociatedTokenAddressSync,
  ASSOCIATED_TOKEN_PROGRAM_ID,
  TOKEN_PROGRAM_ID,
} from '@solana/spl-token';
import {
  web3,
  Program,
  AnchorProvider,
  getProvider,
  setProvider,
  workspace,
  BN,
} from '@coral-xyz/anchor';
import { PROGRAM_ID as TOKEN_METADATA_PROGRAM_ID } from '@metaplex-foundation/mpl-token-metadata';
import { Launchpad } from '../target/types/launchpad';

describe('launchpad', () => {
  const conn = getProvider().connection;
  const provider = AnchorProvider.env();
  setProvider(provider);
  const payer = provider.wallet;
  const program = workspace.Launchpad as Program<Launchpad>;

  const metadata = {
    name: 'Solana Gold',
    symbol: 'GOLDSOL',
    uri: 'https://raw.githubusercontent.com/solana-developers/program-examples/new-examples/tokens/tokens/.assets/spl-token.json',
  };

  // Generate new keypair to use as address for mint account.
  const mintKeypair = web3.Keypair.generate();
  console.log('Mint public key', mintKeypair.publicKey.toBase58());

  const tokenListKeypair = web3.Keypair.generate();
  console.log('Token list public key', tokenListKeypair.publicKey.toBase58());

  const user1 = web3.Keypair.generate();
  console.log('User 1 public key', user1.publicKey.toBase58());

  it('Initialize launchpad!', async () => {
    await program.methods
      .initialize()
      .accounts({
        payer: payer.publicKey,
        systemProgram: web3.SystemProgram.programId,
        tokenList: tokenListKeypair.publicKey,
      })
      .signers([tokenListKeypair])
      .rpc()
      .then((tx) => {
        console.log('launchpad program initialized transaction signature', tx);
      });

    await program.account.tokenList
      .fetch(tokenListKeypair.publicKey)
      .then((tokenList) => {
        expect(tokenList.tokens).toEqual([]);
      });
  });

  it('Create an SPL Token!', async () => {
    await conn
      .requestAirdrop(user1.publicKey, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));
    await conn
      .requestAirdrop(program.provider.publicKey!, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));

    // Derive the metadata account address.
    const [metadataAddress] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from('metadata'),
        TOKEN_METADATA_PROGRAM_ID.toBuffer(),
        mintKeypair.publicKey.toBuffer(),
      ],
      TOKEN_METADATA_PROGRAM_ID
    );

    const transactionSignature = await program.methods
      .createToken(metadata.name, metadata.symbol, metadata.uri)
      .accounts({
        payer: payer.publicKey,
        mintAccount: mintKeypair.publicKey,
        metadataAccount: metadataAddress,
        tokenProgram: TOKEN_PROGRAM_ID,
        tokenMetadataProgram: TOKEN_METADATA_PROGRAM_ID,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
        tokenList: tokenListKeypair.publicKey,
      })
      .signers([mintKeypair])
      .rpc();

    console.log('Success!');
    console.log(`   Mint Address: ${mintKeypair.publicKey}`);
    console.log(`   Transaction Signature: ${transactionSignature}`);

    await program.account.tokenList
      .fetch(tokenListKeypair.publicKey)
      .then((tokenList) => {
        expect(tokenList.tokens).toEqual([mintKeypair.publicKey]);
      });
  });

  it('Mint some tokens to your wallet!', async () => {
    // Derive the associated token address account for the mint and payer.
    const associatedTokenAccountAddress = getAssociatedTokenAddressSync(
      mintKeypair.publicKey,
      payer.publicKey
    );

    // Amount of tokens to mint.
    const amount = new BN(100);

    // Mint the tokens to the associated token account.
    const transactionSignature = await program.methods
      .mintToken(amount)
      .accounts({
        mintAuthority: payer.publicKey,
        recipient: payer.publicKey,
        mintAccount: mintKeypair.publicKey,
        associatedTokenAccount: associatedTokenAccountAddress,
        tokenProgram: TOKEN_PROGRAM_ID,
        associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
        systemProgram: web3.SystemProgram.programId,
      })
      .rpc();

    console.log('Success!');
    console.log(
      `   Associated Token Account Address: ${associatedTokenAccountAddress}`
    );
    console.log(`   Transaction Signature: ${transactionSignature}`);
  });
});
