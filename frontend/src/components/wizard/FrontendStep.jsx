/**
 * @file FrontendStep.jsx
 * @description This component is a step in the wizard that allows the user to configure the frontend.
 * It includes options for selecting the frontend framework, UI library, and other additional options.
 * @requires react
 * @requires prop-types
 */

import React from 'react';
import PropTypes from 'prop-types';

/**
 * A component that allows the user to configure the frontend.
 * @param {object} props - The component's props.
 * @param {Function} props.nextStep - A function to go to the next step in the wizard.
 * @param {Function} props.prevStep - A function to go to the previous step in the wizard.
 * @param {Function} props.handleChange - A function to handle changes to the configuration.
 * @param {object} props.config - The current configuration.
 * @returns {JSX.Element} The frontend step component.
 */
const FrontendStep = ({ nextStep, prevStep, handleChange, config }) => {
  const Continue = (e) => {
    e.preventDefault();
    nextStep();
  };

  return (
    <div className='text-center p-4'>
      <h2 className='text-3xl font-bold mb-2 text-gray-800 dark:text-white'>
        Frontend Configuration
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        Select your frontend framework and UI library.
      </p>

      <div className='mb-6'>
        <label
          htmlFor='frontend-framework-options'
          className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
        >
          Framework
        </label>
        <div
          id='frontend-framework-options'
          className='bg-gray-100 dark:bg-gray-700 border-2 border-blue-500 rounded-lg p-4'
        >
          <span className='font-bold block text-gray-800 dark:text-white'>React + Vite</span>
          <span className='text-sm text-gray-600 dark:text-gray-400'>
            The only option, for now!
          </span>
        </div>
      </div>      <div className='mb-6'>
        <label
          htmlFor='ui-library-select'
          className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
        >
          UI Library
        </label>
        <select
          id='ui-library-select'
          name='uiLibrary'
          value={config.frontend.uiLibrary}
          onChange={handleChange('frontend.uiLibrary')}
          className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
        >
          <option value='none'>None</option>
          <option value='tailwindcss'>Tailwind CSS</option>
          <option value='material-ui'>Material-UI</option>
        </select>
      </div>

      <div className='mb-6 space-y-4'>
        <h3 className='text-xl font-bold text-gray-700 dark:text-gray-200'>
          Additional Options
        </h3>
        <div className='flex flex-wrap gap-4 justify-center'>
          <label className='flex items-center text-lg text-gray-700 dark:text-gray-200'>
            <input
              type='checkbox'
              checked={config.frontend.includeExamplePages}
              onChange={handleChange('frontend.includeExamplePages')}
              className='mr-2 h-5 w-5 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600'
            />{' '}
            Include Example Pages
          </label>
          <label className='flex items-center text-lg text-gray-700 dark:text-gray-200'>
            <input
              type='checkbox'
              checked={config.frontend.includeHusky}
              onChange={handleChange('frontend.includeHusky')}
              className='mr-2 h-5 w-5 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600'
            />{' '}
            Include Husky (Git Hooks)
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
          onClick={Continue}
          className='bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-lg transition-transform transform hover:scale-105'
        >
          Next
        </button>
      </div>
    </div>
  );
};

FrontendStep.propTypes = {
  nextStep: PropTypes.func.isRequired,
  prevStep: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default FrontendStep;
