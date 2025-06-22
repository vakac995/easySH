/**
 * @file DatabaseConfigStep.jsx
 * @description This component is a step in the wizard that allows the user to configure the database.
 * It includes fields for the database name, user, password, port, and PgAdmin credentials.
 * @requires react
 * @requires prop-types
 */
import React from 'react';
import PropTypes from 'prop-types';

/**
 * A component that allows the user to configure the database.
 * @param {object} props - The component's props.
 * @param {Function} props.nextStep - A function to go to the next step in the wizard.
 * @param {Function} props.prevStep - A function to go to the previous step in the wizard.
 * @param {Function} props.handleChange - A function to handle changes to the configuration.
 * @param {object} props.config - The current configuration.
 * @returns {JSX.Element} The database configuration step component.
 */
const DatabaseConfigStep = ({ nextStep, prevStep, handleChange, config }) => {
  const Continue = (e) => {
    e.preventDefault();
    nextStep();
  };

  return (
    <div className='text-center p-4'>
      <h2 className='text-3xl font-bold mb-2 text-gray-800 dark:text-white'>
        Database Configuration
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        Configure your database connection details.
      </p>

      <div className='grid grid-cols-1 md:grid-cols-2 gap-4 mb-6'>
        <div>
          <label
            htmlFor='db-name'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Database Name
          </label>
          <input
            id='db-name'
            type='text'
            value={config.backend.dbName}
            onChange={handleChange('backend.dbName')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='app_db'
          />
        </div>

        <div>
          <label
            htmlFor='db-user'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Database User
          </label>
          <input
            id='db-user'
            type='text'
            value={config.backend.dbUser}
            onChange={handleChange('backend.dbUser')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='db_user'
          />
        </div>

        <div>
          <label
            htmlFor='db-password'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Database Password
          </label>
          <input
            id='db-password'
            type='password'
            value={config.backend.dbPassword}
            onChange={handleChange('backend.dbPassword')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='secure_password_123'
          />
        </div>

        <div>
          <label
            htmlFor='db-port'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            Database Port
          </label>
          <input
            id='db-port'
            type='number'
            value={config.backend.dbPort}
            onChange={handleChange('backend.dbPort')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='5432'
          />
        </div>

        <div>
          <label
            htmlFor='pgadmin-email'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            PgAdmin Email
          </label>
          <input
            id='pgadmin-email'
            type='email'
            value={config.backend.pgAdminEmail}
            onChange={handleChange('backend.pgAdminEmail')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='admin@example.com'
          />
        </div>

        <div>
          <label
            htmlFor='pgadmin-password'
            className='block text-lg font-semibold mb-2 text-gray-700 dark:text-gray-200'
          >
            PgAdmin Password
          </label>
          <input
            id='pgadmin-password'
            type='password'
            value={config.backend.pgAdminPassword}
            onChange={handleChange('backend.pgAdminPassword')}
            className='w-full p-3 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
            placeholder='admin123'
          />        </div>
      </div>

      <div className='mb-6'>        <label className='flex items-center justify-center text-lg text-gray-700 dark:text-gray-200'>
          <input
            type='checkbox'
            checked={config.backend.debug}
            onChange={handleChange('backend.debug')}
            className='mr-2 h-5 w-5 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600'
          />{' '}
          Enable Debug Mode
        </label>
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

DatabaseConfigStep.propTypes = {
  nextStep: PropTypes.func.isRequired,
  prevStep: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default DatabaseConfigStep;
