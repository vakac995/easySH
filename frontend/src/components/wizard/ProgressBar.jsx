import React from 'react';
import PropTypes from 'prop-types';

const ProgressBar = ({ currentStep, totalSteps }) => {
  const percentage = (currentStep / totalSteps) * 100;

  return (
    <div className='progress-bar-container'>
      <div className='progress-bar' style={{ width: `${percentage}%` }}></div>
    </div>
  );
};

ProgressBar.propTypes = {
  currentStep: PropTypes.number.isRequired,
  totalSteps: PropTypes.number.isRequired,
};

export default ProgressBar;
