import { Component } from 'react';
import { getPiggyBankContract } from '../../../../../config/instances/contractinstances';
import web3 from '../../../../../config/web3';
import InterestNFTs from './InterestNFTs';

class InterestNFTsContainer extends Component {
  onRedeemClick = async (tokenId) => {
    const accounts = await web3.eth.getAccounts();
    const piggyBankContract = await getPiggyBankContract(web3);
    console.log('tokenId=====', tokenId);
    await piggyBankContract.methods.withdrawNFT(0, accounts[0], tokenId).send({
      from: accounts[0],
    });
  }

  render() {
    return (
      <InterestNFTs
        heading={this.props.heading}
        nftsList={this.props.nftsList}
        onRedeemClick={this.onRedeemClick}
      />
    );
  }
}

export default InterestNFTsContainer;
