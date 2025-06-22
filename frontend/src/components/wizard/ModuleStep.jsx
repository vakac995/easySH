/**
 * @file ModuleStep.jsx
 * @description This component is a step in the wizard that allows the user to select additional modules to include in the project.
 * @requires react
 * @requires prop-types
 */

import React from 'react';
import PropTypes from 'prop-types';

/**
 * A component that allows the user to select additional modules.
 * @param {object} props - The component's props.
 * @param {Function} props.nextStep - A function to go to the next step in the wizard.
 * @param {Function} props.prevStep - A function to go to the previous step in the wizard.
 * @param {Function} props.handleChange - A function to handle changes to the configuration.
 * @param {object} props.config - The current configuration.
 * @returns {JSX.Element} The module step component.
 */
const ModuleStep = ({ nextStep, prevStep, handleChange, config }) => {
  return (
    <div className='text-center p-4'>
      <h2 className='text-3xl font-bold mb-2 text-gray-800 dark:text-white'>
        Module Configuration
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        Select any additional modules you'd like to include.
      </p>

      <div className='mb-6'>
        <label
          htmlFor='module-options'
          className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
        >
          Modules
        </label>{' '}
        <div id='module-options' className='flex flex-wrap justify-center gap-4 max-w-full'>
          <label className='flex items-center text-lg text-gray-700 dark:text-gray-200 whitespace-nowrap'>
            <input
              type='checkbox'
              name='authentication'
              checked={config.modules.authentication}
              onChange={handleChange('modules.authentication')}
              className='mr-2 h-5 w-5 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600'
            />
            {''}
            Authentication
          </label>
          <label className='flex items-center text-lg text-gray-700 dark:text-gray-200 whitespace-nowrap'>
            <input
              type='checkbox'
              name='notifications'
              checked={config.modules.notifications}
              onChange={handleChange('modules.notifications')}
              className='mr-2 h-5 w-5 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600'
            />
            {''}
            Notifications
          </label>
        </div>
      </div>

      <div className='flex justify-between mt-8'>
        <button
          onClick={prevStep}
          className='bg-gray-500 hover:bg-gray-600 text-white font-bold py-2 px-6 rounded-lg transition-transform transform hover:scale-105'
        >
          Back
        </button>
        <button
          onClick={nextStep}
          className='bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-lg transition-transform transform hover:scale-105'
        >
          Next
        </button>
      </div>
    </div>
  );
};

ModuleStep.propTypes = {
  nextStep: PropTypes.func.isRequired,
  prevStep: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default ModuleStep;
