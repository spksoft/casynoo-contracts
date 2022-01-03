const { assert } = require('chai');

const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

const HiLow = artifacts.require('HiLow');
const CSCHIPToken = artifacts.require('CSCHIPToken');

contract('HiLow', async function([ owner, player1 ]) {

  beforeEach(async function() {
    this.token = await CSCHIPToken.new({ from: owner })
    this.hiLow = await HiLow.new(this.token.address, true, { from: owner })
    await this.token.transfer(this.hiLow.address, 100000, { from: owner }) // transfer 100000 CSCHIP to HiLow
    await this.token.transfer(player1, 100000, { from: owner }) // transfer 100000 CSCHIP to HiLow
  })

  it("should return true when call getIsTest", async function() {
    const isTest = await this.hiLow.getIsTest()
    assert.equal(isTest, true)
  })

  it("it should return 100000 when getPrizePoolBalance", async function() {
    const balance = await this.hiLow.getPrizePoolBalance()
    assert.equal(balance, 100000)
  })

  it("should transfer prize pool to owner account success when it called by owner", async function() {
    await this.hiLow.transferFromPrizePoolToOwner(10, { from: owner })
    const balance = await this.hiLow.getPrizePoolBalance()
    assert.equal(balance, 100000 - 10)
  })

  it("should got transaction reject when other call transferFromPrizePoolToOwner", async function() {
    await expectRevert(this.hiLow.transferFromPrizePoolToOwner(10, { from: player1 }), "Ownable: caller is not the owner")
  })

  it("should return address of player1 as winner when player1 pick 'Higher'", async function() {
    const isHigher = true
    const betSize = 1
    await this.token.approve(this.hiLow.address, betSize, { from: player1 })
    const txt = await this.hiLow.play(isHigher, betSize, { from: player1 })
    expectEvent(txt, 'EndGame', { winner: player1 })
  })

  it("should return address of contract as winner when player1 pick Lower", async function() {
    const isHigher = false
    const betSize = 1
    await this.token.approve(this.hiLow.address, betSize, { from: player1 })
    const txt = await this.hiLow.play(isHigher, betSize, { from: player1 })
    expectEvent(txt, 'EndGame', { winner: this.hiLow.address })
  })

  it("should return address of player1 as winner when they pick Higher with mockBlockDiff is 4 and mockBlockTime is 1", async function() {
    const isHigher = true
    const betSize = 1
    await this.hiLow.setMockBlockDiff(4, { from: owner })
    await this.hiLow.setMockBlockTime(1, { from: owner })
    await this.token.approve(this.hiLow.address, betSize, { from: player1 })
    const txt = await this.hiLow.play(isHigher, betSize, { from: player1 })
    expectEvent(txt, 'EndGame', { winner: player1 })
  })

  it("should return address of contract as winner when player1 pick Higher with mockBlockDiff is 1 and mockBlockTime is 1", async function() {
    const isHigher = true
    const betSize = 1
    await this.hiLow.setMockBlockDiff(1, { from: owner })
    await this.hiLow.setMockBlockTime(1, { from: owner })
    await this.token.approve(this.hiLow.address, betSize, { from: player1 })
    const txt = await this.hiLow.play(isHigher, betSize, { from: player1 })
    expectEvent(txt, 'EndGame', { winner:this.hiLow.address })
  })

})