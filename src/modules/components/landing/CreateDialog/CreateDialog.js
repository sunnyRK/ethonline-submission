import React from 'react';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import InputLabel from '@material-ui/core/InputLabel';
import { Button } from '@material-ui/core';

const options = [
  {
    key: 'compound',
    text: 'Compound',
    value: 'compound',
  },
  {
    key: 'aave',
    text: 'Aave',
    value: 'aave',
  },
  {
    key: 'yearn',
    text: 'Yearn',
    value: 'yearn',
  },
];

const totalWinnerOptions = [
  {
    key: 1,
    text: 1,
    value: 1,
  },
  {
    key: 2,
    text: 2,
    value: 2,
  },
  {
    key: 3,
    text: 3,
    value: 3,
  },
];

const CreateDialog = ({ handleState, onCreateClick, podName, joinAmt, totalDays, numStakers }) => (
  <form onSubmit={onCreateClick} className="join-dialog-content">
    <div className="form-field">
      <FormControl fullWidth variant="outlined" classes={{ root: 'token-price-dropdown' }}>
        <InputLabel>Lending Choice</InputLabel>
        <Select
          label="Lending Choice"
          onChange={(event) => handleState({ lendingChoice: event.target.value })}
        >
          {
            options.map((option) => (
              <MenuItem value={option.value}>{option.text}</MenuItem>
            ))
          }
        </Select>
      </FormControl>
    </div>
    <div className="form-field">
      <TextField
        label="Pod Name"
        variant="outlined"
        fullWidth
        required
        value={podName}
        onChange={(event) => {
          handleState({ podName: event.target.value });
        }}
      />
    </div>
    <div className="form-field">
      <FormControl fullWidth variant="outlined" classes={{ root: 'token-price-dropdown' }}>
        <InputLabel>Total Winner</InputLabel>
        <Select
          label="Total Winner"
          onChange={(event) => handleState({ totalWinner: event.target.value })}
        >
          {
            totalWinnerOptions.map((option) => (
              <MenuItem value={option.value}>{option.text}</MenuItem>
            ))
          }
        </Select>
      </FormControl>
    </div>
    <div className="form-field">
      <TextField
        label="Join Amount (in $)"
        variant="outlined"
        fullWidth
        required
        value={joinAmt}
        onChange={(event) => {
          handleState({ joinAmt: event.target.value });
        }}
      />
    </div>
    <div className="form-field">
      <TextField
        label="Total Days"
        variant="outlined"
        fullWidth
        required
        value={totalDays}
        onChange={(event) => {
          handleState({ totalDays: event.target.value });
        }}
      />
    </div>
    <div className="form-field">
      <TextField
        label="Num of Stakers can participant"
        variant="outlined"
        fullWidth
        required
        value={numStakers}
        onChange={(event) => {
          handleState({ numStakers: event.target.value });
        }}
      />
    </div>
    <div className="form-field join-dialog-footer">
      <Button
        className="join-submit-button"
        variant="outlined"
        type="submit"
      >
        Create
      </Button>
    </div>
  </form>
);

export default CreateDialog;
