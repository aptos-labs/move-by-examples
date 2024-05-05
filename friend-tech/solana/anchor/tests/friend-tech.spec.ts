import {
  web3,
  Program,
  AnchorProvider,
  getProvider,
  setProvider,
  workspace,
  BN,
  utils,
} from '@coral-xyz/anchor';
import { FriendTech } from '../target/types/friend_tech';

describe('friend-tech', () => {
  setProvider(AnchorProvider.env());

  const program = workspace.FriendTech as Program<FriendTech>;

  const admin = web3.Keypair.generate();
  const user1 = web3.Keypair.generate();

  const conn = getProvider().connection;

  it('Is initialized!', async () => {
    await conn
      .requestAirdrop(admin.publicKey, 1e9)
      .then((sig) => conn.confirmTransaction(sig));
    await conn
      .requestAirdrop(user1.publicKey, 1e9)
      .then((sig) => conn.confirmTransaction(sig));

    const [config] = web3.PublicKey.findProgramAddressSync(
      [Buffer.from(utils.bytes.utf8.encode('config'))],
      program.programId
    );

    const [vault, vaultBump] = web3.PublicKey.findProgramAddressSync(
      [Buffer.from(utils.bytes.utf8.encode('vault'))],
      program.programId
    );

    const tx = await program.methods
      .initialize()
      .accounts({
        config,
        signer: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc();
    console.log('Your transaction signature', tx);

    // user 1 is issuer
    const [issuer, issuerBump] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from(utils.bytes.utf8.encode('issuer')),
        user1.publicKey.toBuffer(),
      ],
      program.programId
    );

    // user 1's holding of keys issued by itself
    const [holding1] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from(utils.bytes.utf8.encode('holding')),
        user1.publicKey.toBuffer(),
        user1.publicKey.toBuffer(),
      ],
      program.programId
    );

    // user 1 issues its key
    await program.methods
      .issueKey(issuerBump, 'user1')
      .accounts({
        config,
        issuer,
        holding: holding1,
        issuerPubkey: user1.publicKey,
        signer: user1.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([user1])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig));
    await program.account.issuer.fetch(issuer).then((value) => {
      expect(value.issuer.toBase58()).toEqual(user1.publicKey.toBase58());
      expect(value.username).toEqual('user1');
      expect(value.shares).toEqual(1);
    });

    // admin's holding of keys issued by user 1
    const [holding2] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from(utils.bytes.utf8.encode('holding')),
        user1.publicKey.toBuffer(),
        admin.publicKey.toBuffer(),
      ],
      program.programId
    );

    // user 1 buys 10 keys of itself
    await program.methods
      .buyHoldings(new BN(10))
      .accounts({
        issuer,
        holding: holding1,
        issuerPubkey: user1.publicKey,
        vault: vault,
        signer: user1.publicKey,
        config,
        admin: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([user1])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig));
    await program.account.holding.fetch(holding1).then((value) => {
      expect(value.shares).toEqual(11);
    });
    await program.account.issuer.fetch(issuer).then((value) => {
      expect(value.shares).toEqual(11);
    });

    // admin buy 10 keys of user 1
    await program.methods
      .buyHoldings(new BN(10))
      .accounts({
        issuer,
        holding: holding2,
        issuerPubkey: user1.publicKey,
        vault: vault,
        signer: admin.publicKey,
        config,
        admin: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig));
    await program.account.holding.fetch(holding1).then((value) => {
      expect(value.shares).toEqual(11);
    });
    await program.account.holding.fetch(holding2).then((value) => {
      expect(value.shares).toEqual(10);
    });
    await program.account.issuer.fetch(issuer).then((value) => {
      expect(value.shares).toEqual(21);
    });

    // admin sell 1 keys of user 1
    await program.methods
      .sellHoldings(vaultBump, new BN(1))
      .accounts({
        issuer,
        holding: holding2,
        issuerPubkey: user1.publicKey,
        vault: vault,
        signer: admin.publicKey,
        config,
        admin: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig));
    await program.account.holding.fetch(holding1).then((value) => {
      expect(value.shares).toEqual(11);
    });
    await program.account.holding.fetch(holding2).then((value) => {
      expect(value.shares).toEqual(9);
    });
    await program.account.issuer.fetch(issuer).then((value) => {
      expect(value.shares).toEqual(20);
    });

    await conn.getBalance(vault).then((value) => {
      console.log('vault balance: ', value);
    });
  });
});
