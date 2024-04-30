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
    await conn
      .requestAirdrop(program.provider.publicKey!, 1e9)
      .then((sig) => conn.confirmTransaction(sig));

    const [config, configBump] = web3.PublicKey.findProgramAddressSync(
      [Buffer.from(utils.bytes.utf8.encode('config'))],
      program.programId
    );

    const [vault, vaultBump] = web3.PublicKey.findProgramAddressSync(
      [Buffer.from(utils.bytes.utf8.encode('vault'))],
      program.programId
    );

    const tx = await program.methods
      .initialize(configBump)
      .accounts({
        config,
        signer: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc();
    console.log('Your transaction signature', tx);

    const [issuerShare, issuerShareBump] =
      web3.PublicKey.findProgramAddressSync(
        [
          Buffer.from(utils.bytes.utf8.encode('issuer_share')),
          user1.publicKey.toBuffer(),
        ],
        program.programId
      );

    await program.methods
      .initIssuerShare(issuerShareBump, configBump)
      .accounts({
        config,
        issuerShare,
        issuerPubkey: user1.publicKey,
        socialMediaHandle: user1.publicKey,
        signer: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig))
      .catch(console.log);

    const [holding, holdingBump] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from(utils.bytes.utf8.encode('holding')),
        user1.publicKey.toBuffer(),
        user1.publicKey.toBuffer(),
      ],
      program.programId
    );

    await program.methods
      .initIssuerHolding(holdingBump, configBump)
      .accounts({
        config,
        issuerShare,
        holding,
        issuerPubkey: user1.publicKey,
        signer: admin.publicKey,
        systemProgram: web3.SystemProgram.programId,
        rent: web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([admin])
      .rpc()
      .then((sig) => conn.confirmTransaction(sig))
      .catch(console.log);

    const [newHolding, newHoldingBump] = web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from(utils.bytes.utf8.encode('holding')),
        user1.publicKey.toBuffer(),
        admin.publicKey.toBuffer(),
      ],
      program.programId
    );

    await program.methods
      .buyHoldings(newHoldingBump, vaultBump, configBump, 1, new BN(10))
      .accounts({
        issuerShare,
        holding: newHolding,
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
      .then((sig) => conn.confirmTransaction(sig))
      .then(console.log)
      .catch(console.log);
    await conn.getBalance(vault).then(console.log);

    await program.methods
      .buyHoldings(newHoldingBump, vaultBump, configBump, 11, new BN(10))
      .accounts({
        issuerShare,
        holding: newHolding,
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
      .then((sig) => conn.confirmTransaction(sig))
      .then(console.log)
      .catch(console.log);
    await conn.getBalance(vault).then(console.log);

    await program.methods
      .sellHoldings(newHoldingBump, vaultBump, configBump, 21, new BN(1))
      .accounts({
        issuerShare,
        holding: newHolding,
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
      .then((sig) => conn.confirmTransaction(sig))
      .then(console.log)
      .catch(console.log);

    await program.account.issuerShare.fetch(issuerShare).then(console.log);
    await program.account.holding.fetch(holding).then(console.log);
    await conn.getBalance(vault).then(console.log);
  });
});
