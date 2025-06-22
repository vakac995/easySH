/**
 * @file WelcomeStep.jsx
 * @description This component is the first step in the wizard, welcoming the user and asking for basic project information.
 * @requires react
 * @requires prop-types
 * @requires framer-motion
 * @requires ./Mascot
 */

import React from 'react';
import PropTypes from 'prop-types';
import { motion } from 'framer-motion';
import Mascot from './Mascot';

/**
 * A component that displays the welcome step of the wizard.
 * @param {object} props - The component's props.
 * @param {Function} props.nextStep - A function to go to the next step in the wizard.
 * @param {Function} props.handleChange - A function to handle changes to the configuration.
 * @param {object} props.config - The current configuration.
 * @returns {JSX.Element} The welcome step component.
 */
const WelcomeStep = ({ nextStep, handleChange, config }) => {
  const Continue = (e) => {
    e.preventDefault();
    nextStep();
  };

  return (
    <div className='text-center p-4'>
      <Mascot />
      <h2 className='text-4xl font-bold mb-2 text-gray-800 dark:text-white'>
        Welcome to the Project Generator!
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        I'm your friendly assistant. Let's build something amazing together!
      </p>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        First, let's set up your project basics.
      </p>
      <div className='w-full max-w-lg mx-auto mb-6 space-y-4'>
        <div>
          <label
            htmlFor='projectName'
            className='block text-xl font-bold mb-2 text-gray-700 dark:text-gray-200'
          >
            Project Name
          </label>
          <input
            type='text'
            id='projectName'
            name='projectName'
            value={config.projectName}
            onChange={handleChange('projectName')}
            placeholder='e.g., MyAwesomeApp'
            className='w-full max-w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 box-border'
          />
        </div>
      </div>
      <motion.button
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        onClick={Continue}
        className='bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-lg transition-transform transform hover:scale-105'
      >
        Let's Go!
      </motion.button>
    </div>
  );
};

WelcomeStep.propTypes = {
  nextStep: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default WelcomeStep;
