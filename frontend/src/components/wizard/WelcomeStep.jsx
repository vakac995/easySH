import React from 'react';
import PropTypes from 'prop-types';
import { motion } from 'framer-motion';
import Mascot from './Mascot';

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
      </p>      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        First, let's set up your project basics.
      </p>{' '}
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
        
        <div>
          <label
            htmlFor='projectDescription'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Project Description
          </label>
          <textarea
            id='projectDescription'
            name='projectDescription'
            value={config.backend.projectDescription}
            onChange={handleChange('backend.projectDescription')}
            placeholder='A brief description of your project...'
            rows={3}
            className='w-full max-w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 box-border'
          />
        </div>
        
        <div>
          <label
            htmlFor='projectVersion'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Initial Version
          </label>
          <input
            type='text'
            id='projectVersion'
            name='projectVersion'
            value={config.backend.projectVersion}
            onChange={handleChange('backend.projectVersion')}
            placeholder='0.1.0'
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
