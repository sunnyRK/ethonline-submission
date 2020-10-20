import React from 'react';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import { Button } from '@material-ui/core';

const JoinDialog = ({ onJoinClick, options, handleState }) => (
  <div className="join-dialog-content">
    <FormControl fullWidth variant="outlined" classes={{ root: 'token-price-dropdown' }}>
      <InputLabel>Choose Your Token</InputLabel>
      <Select
        label="Choose Your Token"
        onChange={(event) => handleState({ token: event.target.value })}
      >
        {
          options.map((option) => (
            <MenuItem value={option.value}>{option.text}</MenuItem>
          ))
        }
      </Select>
    </FormControl>
    <div className="form-field join-dialog-footer">
      <Button
        className="join-submit-button"
        variant="outlined"
        onClick={() => onJoinClick()}
      >
        Join
      </Button>
    </div>
  </div>
);

export default JoinDialog;
