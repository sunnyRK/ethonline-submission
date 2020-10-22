import { Component } from 'react';
import { getPodStorageContract } from '../../../../config/instances/contractinstances';
import web3 from '../../../../config/web3';
import NFTs from './NFTs';

// const InterestNFTsList = [];
// const PaticipantNFTsList = [];

class NFTsContainer extends Component {

  state = {
    InterestNFTsList: [],
    ParticipantNFTsList: [],
  };

  async componentDidMount() {
    const accounts = await web3.eth.getAccounts();
    const podContract = await getPodStorageContract(web3);
    const betIdArrayOfStaker = await podContract.methods.getBetIdArrayOfStaker(accounts[0]).call();
    for (let i = 0; i < betIdArrayOfStaker.length; i++) {
      const winningNFTDetails = await podContract.methods.getInterestNftDetail(betIdArrayOfStaker[i], accounts[0]).call();
      const NFTDetails = await podContract.methods.getNftDetail(betIdArrayOfStaker[i], accounts[0]).call();
      let tempWinningNFT = {};
      if (winningNFTDetails[0] !== '0') {
        tempWinningNFT = {
          key: i,
          tokenId: winningNFTDetails[0],
          price: `$${web3.utils.fromWei(Number(winningNFTDetails[1]).toString(), 'ether')}`,
          isDead: winningNFTDetails[2],
        };
        this.state.InterestNFTsList.push(tempWinningNFT);
      }

      const tempNFT = {
        key: i,
        tokenId: NFTDetails[0],
        price: `$${Number(NFTDetails[1]) / 1e18}`,
        isDead: NFTDetails[2],
      };
      this.state.ParticipantNFTsList.push(tempNFT);
    }
  }

  render() {
    return (
      <NFTs
      InterestNFTsList={this.state.InterestNFTsList}
      ParticipantNFTsList={this.state.ParticipantNFTsList}
    />
    )
  }
}

export default NFTsContainer;
