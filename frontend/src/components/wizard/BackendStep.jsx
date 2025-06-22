/**
 * @file BackendStep.jsx
 * @description This component is a step in the wizard that allows the user to configure the backend.
 * It includes options for selecting the backend framework and database.
 * @requires react
 * @requires prop-types
 */
import React from 'react';
import PropTypes from 'prop-types';

/**
 * A component that allows the user to configure the backend.
 * @param {object} props - The component's props.
 * @param {Function} props.nextStep - A function to go to the next step in the wizard.
 * @param {Function} props.prevStep - A function to go to the previous step in the wizard.
 * @param {Function} props.handleChange - A function to handle changes to the configuration.
 * @param {object} props.config - The current configuration.
 * @returns {JSX.Element} The backend step component.
 */
const BackendStep = ({ nextStep, prevStep, handleChange, config }) => {
  const Continue = (e) => {
    e.preventDefault();
    nextStep();
  };

  return (
    <div className='text-center p-4'>
      <h2 className='text-3xl font-bold mb-2 text-gray-800 dark:text-white'>
        Backend Configuration
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        Choose your backend framework and database.
      </p>

      <div className='mb-6'>
        <label
          htmlFor='framework-options'
          className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
        >
          Framework
        </label>
        <div
          id='framework-options'
          className='bg-gray-100 dark:bg-gray-700 border-2 border-blue-500 rounded-lg p-4'
        >
          <span className='font-bold block text-gray-800 dark:text-white'>FastAPI</span>
          <span className='text-sm text-gray-600 dark:text-gray-400'>
            The only option, for now!
          </span>
        </div>
      </div>

      <div className='mb-6'>
        <textarea
          value={config.backend.projectDescription}
          onChange={handleChange('backend.projectDescription')}
          placeholder='Enter backend description'
          className='w-full p-3 mt-4 bg-gray-50 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white'
        />
      </div>

      <div className='mb-6'>
        <label
          htmlFor='database-select'
          className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
        >
          Database
        </label>
        <select
          id='database-select'
          name='database'
          value={config.backend.database}
          onChange={handleChange('backend.database')}
          className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
        >
          <option value='postgresql'>PostgreSQL</option>
          <option value='sqlite'>SQLite</option>
        </select>
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

BackendStep.propTypes = {
  nextStep: PropTypes.func.isRequired,
  prevStep: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default BackendStep;
