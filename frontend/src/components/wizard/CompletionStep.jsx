import React from 'react';
import PropTypes from 'prop-types';
import { motion } from 'framer-motion';

const CompletionStep = ({ config, startOver }) => {
  return (
    <motion.div
      className='text-center p-8'
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <h2 className='text-4xl font-bold text-green-500 mb-4'>Congratulations!</h2>
      <p className='text-xl mb-8 text-gray-800 dark:text-white'>
        Your project, <strong>{config.projectName}</strong>, has been successfully generated.
      </p>
      <div className='text-left max-w-md mx-auto mb-8 p-6 bg-gray-100 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700'>
        <h3 className='text-2xl font-bold mb-4 text-gray-800 dark:text-white'>What's next?</h3>
        <ul className='list-disc list-inside text-gray-700 dark:text-gray-300'>
          <li className='mb-2'>Unzip the downloaded file.</li>
          <li className='mb-2'>Open the project in your favorite editor.</li>
          <li className='mb-2'>Follow the instructions in the `README.md` to get started.</li>
          <li>Run the `setup_environment.sh` script to set up your local environment.</li>
        </ul>
      </div>
      <motion.button
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        onClick={startOver}
        className='bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-6 text-xl rounded-lg cursor-pointer'
      >
        Create Another Project
      </motion.button>
    </motion.div>
  );
};

CompletionStep.propTypes = {
  config: PropTypes.object.isRequired,
  startOver: PropTypes.func.isRequired,
};

export default CompletionStep;
