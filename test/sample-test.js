const LandManager = artifacts.require('LandManager');
const Ballot = artifacts.require('Ballot');

const { constants } = require('@openzeppelin/test-helpers');

describe('LandManager', function () {
  beforeEach(async () => {
    await deployments.fixture(['land_manager']);
    let deployment = await deployments.get('LandManager');
    this.landContract = await LandManager.at(deployment.address);
  });

  it('deployed successfuly', async () => {
    const address = this.landContract.address;
    assert.notEqual(address, '');
    assert.notEqual(address, null);
    assert.notEqual(address, undefined);
    assert.notEqual(address, 0x0);
  });

  it('get map dimensions', async () => {
    const hight = await this.landContract.getHight();
    const width = await this.landContract.getWidth();

    // Success
    assert.equal(hight, 5);
    assert.equal(width, 6);
  });

  describe('ask for lands (1,1)(2,2)', async () => {
    beforeEach(async () => {
      const { user1 } = await getNamedAccounts();
      await this.landContract.askForLands(1, 1, 2, 2, { from: user1 });

      const ballot = await this.landContract.getBallot(user1);
      this.ballot = await Ballot.at(ballot);
    });

    it('check ballot creation', async () => {
      // Success
      assert.notEqual(this.ballot.address, constants.ZERO_ADDRESS);
    });

    it('vote on ballot', async () => {
      await this.ballot.vote(1);
      const proposal = await this.ballot.getProposal(1);

      // Success
      // console.log('proposal', proposal);
      assert.equal(proposal.voteCount, 1);
    });

    it('check lands assignation', async () => {
      const { user1 } = await getNamedAccounts();
      let grantedLands = await this.landContract.getGrantedLands();
      await this.ballot.vote(1);
      await this.landContract.checkBallot(user1);
      let newGrantedLands = await this.landContract.getGrantedLands();

      // Success
      // console.log('newGrantedLands', newGrantedLands);
      assert.equal(newGrantedLands.length, grantedLands.length + 1);
      assert.equal(newGrantedLands[0].owner, user1);
    });
  });

  describe('ask for extend lands (7,7)(8,8)', async () => {
    beforeEach(async () => {
      // asign lands
      const { user1 } = await getNamedAccounts();
      await this.landContract.askForLands(1, 1, 2, 2, { from: user1 });

      const firstBallot = await this.landContract.getBallot(user1);
      this.firstBallot = await Ballot.at(firstBallot);
      // vote
      await this.firstBallot.vote(1);
      // accept the land assignation
      await this.landContract.checkBallot(user1);

      // ---------------------------------------------- //
      // ask for extend lands
      const { user2 } = await getNamedAccounts();
      await this.landContract.askForLands(7, 7, 8, 8, { from: user2 });

      const ballot = await this.landContract.getBallot(user2);
      this.ballot = await Ballot.at(ballot);
    });

    it('check ballot entension creation', async () => {
      // Success
      assert.notEqual(this.ballot.address, constants.ZERO_ADDRESS);
    });

    it('vote on ballot the 2 owners', async () => {
      const { user1 } = await getNamedAccounts();
      await this.ballot.vote(1);
      await this.ballot.vote(1, { from: user1 });

      const proposal = await this.ballot.getProposal(1);

      // Success
      // console.log('proposal', proposal);
      assert.equal(proposal.voteCount, 2);
    });

    it('check lands assignation and extension', async () => {
      const { user2 } = await getNamedAccounts();
      let grantedLands = await this.landContract.getGrantedLands();
      await this.ballot.vote(1);
      await this.landContract.checkBallot(user2);
      let newGrantedLands = await this.landContract.getGrantedLands();

      // Success
      // console.log('newGrantedLands', newGrantedLands);
      assert.equal(newGrantedLands.length, grantedLands.length + 1);
      assert.equal(newGrantedLands[1].owner, user2);

      // check land extension
      const hight = await this.landContract.getHight();
      const width = await this.landContract.getWidth();

      // console.log('width', width);
      // console.log('hight', hight);

      assert.equal(width, 7);
      assert.equal(hight, 8);
    });
  });
});
