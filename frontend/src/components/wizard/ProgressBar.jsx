/**
 * @file ProgressBar.jsx
 * @description This component displays a progress bar that shows the user's progress through the wizard.
 * @requires react
 * @requires prop-types
 */
import React from 'react';
import PropTypes from 'prop-types';

/**
 * A component that displays a progress bar.
 * @param {object} props - The component's props.
 * @param {number} props.currentStep - The current step in the wizard.
 * @param {number} props.totalSteps - The total number of steps in the wizard.
 * @returns {JSX.Element} The progress bar component.
 */
const ProgressBar = ({ currentStep, totalSteps }) => {
  const percentage = totalSteps > 0 ? (currentStep / totalSteps) * 100 : 0;

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
