import React, { Component } from 'react';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import DialogContent from '@material-ui/core/DialogContent';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';

import CreateDialog from './CreateDialog';
import web3 from '../../../../../config/web3';
import { getPodFactoryContract, getPodStorageContract, TokenInfoArray } from '../../../../../config/instances/contractinstances';
import { AAVE, COMPOUND, YEARN } from '../../../shared/Types';

class CreateDialogContainer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      lendingChoice: '',
      podName: '',
      joinAmt: '',
      totalDays: '',
      totalWinner: 1,
    };
  }

  onCreateClick = async (event) => {
    const {
      lendingChoice, joinAmt, totalDays,
      podName, totalWinner,
    } = this.state;
    const { handleState } = this.props;
    event.preventDefault();
    handleState({ isCreateDialogOpen: false });
    const accounts = await web3.eth.getAccounts();

    const podContract = await getPodStorageContract(web3);

    const betIds = await podContract.methods.getBetIdArrayOfManager(accounts[0]).call();
    let isWinnerDeclareofLast = false;
    let isWinnerDeclareofCurrent = false;
    let winnerAddress;

    if (betIds.length <= 0) {
      isWinnerDeclareofLast = true;
      isWinnerDeclareofCurrent = true;
    } else if (betIds.length === 1) {
      isWinnerDeclareofLast = true;
      winnerAddress = await podContract.methods.getSingleWinnerAddress(betIds[betIds.length - 1]).call();
      if (winnerAddress !== '0x0000000000000000000000000000000000000000') {
        isWinnerDeclareofCurrent = true;
      }
    } else {
      isWinnerDeclareofLast = await podContract.methods.getWinnerDeclare(betIds[betIds.length - 2]).call();
      winnerAddress = await podContract.methods.getSingleWinnerAddress(betIds[betIds.length - 1]).call();
      if (winnerAddress !== '0x0000000000000000000000000000000000000000') {
        isWinnerDeclareofCurrent = true;
      }
    }

    // if (isWinnerDeclareofLast && isWinnerDeclareofCurrent) {
      const isAave = lendingChoice === AAVE;
      const isCompound = lendingChoice === COMPOUND;
      const podFactoryContract = await getPodFactoryContract(web3);
      await podFactoryContract.methods.createPod(
        isAave ? 0 : isCompound && 1,
        web3.utils.toWei(joinAmt.toString(), 'ether'),
        Number(totalDays),
        totalWinner,
        isAave ? TokenInfoArray.AAVEDAI.token_contract_address
          : isCompound && TokenInfoArray.COMPOUNDDAI.token_contract_address,
        isAave ? TokenInfoArray.AAVEDAI.sub_token_address
          : isCompound && TokenInfoArray.COMPOUNDDAI.sub_token_address,
        podName,
      ).send({
        from: accounts[0],
      });
    // } else {
    //   alert('Please wait for disburse old pod!');
    // }
  }

  handleState = (value, callback) => {
    this.setState(value, () => {
      if (callback) callback();
    });
  }

  render() {
    const {
      openDialog, handleState, podName, joinAmt,
      totalDays,
    } = this.props;
    return (
      <Dialog
        className="custom-dialog custom-content-style join-dialog"
        open={openDialog}
      >
        <DialogTitle className="dialog-title">
          Create Pod
          <IconButton
            onClick={() => { handleState({ isCreateDialogOpen: false }); }}
          >
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent className="dialog-content join-dialog">
          <CreateDialog
            handleState={this.handleState}
            onCreateClick={this.onCreateClick}
            podName={podName}
            joinAmt={joinAmt}
            totalDays={totalDays}
          />
        </DialogContent>
      </Dialog>
    );
  }
}

export default CreateDialogContainer;
