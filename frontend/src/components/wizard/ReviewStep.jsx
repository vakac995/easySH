import React from 'react';
import PropTypes from 'prop-types';

// This helper function transforms the frontend's wizard state into the
// exact JSON structure expected by the backend's Pydantic models.
const transformConfigForApi = (config) => {
  const { projectName, backend, frontend, modules } = config;

  // Transform modules to the expected format for frontend only
  const frontendModules = Object.entries(modules)
    .filter(([, enabled]) => enabled)
    .map(([id]) => ({
      id: id,
      name: `${id.charAt(0).toUpperCase() + id.slice(1)}`,
      permissions: 'read,write',
    }));

  // Convert features to the expected format for frontend only
  const frontendFeatures = Object.entries(modules)
    .filter(([, enabled]) => enabled)
    .map(([id]) => ({
      id: id,
    }));
  return {
    global: {
      projectName: projectName,
    },
    backend: {
      include: backend.include,
      projectName: backend.projectName || `${projectName}-backend`,
      projectDescription: backend.projectDescription,
      projectVersion: backend.projectVersion,
      dbHost: backend.dbHost,
      dbPort: parseInt(backend.dbPort),
      dbName: backend.dbName,
      dbUser: backend.dbUser,
      dbPassword: backend.dbPassword,
      pgAdminEmail: backend.pgAdminEmail,
      pgAdminPassword: backend.pgAdminPassword,
      debug: backend.debug,
      logLevel: backend.logLevel,
    },
    frontend: {
      include: frontend.include,
      projectName: frontend.projectName || `${projectName}-frontend`,
      includeExamplePages: frontend.includeExamplePages,
      includeHusky: frontend.includeHusky,
      moduleSystem: {
        include: frontendModules.length > 0,
        modules: frontendModules,
        features: frontendFeatures,
      },
    },
  };
};

const ReviewStep = ({ prevStep, nextStep, config }) => {
  const submit = async () => {
    const apiPayload = transformConfigForApi(config);
    try {
      const response = await fetch('http://localhost:8000/api/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(apiPayload),
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${apiPayload.global.projectName}.zip`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        nextStep();
      } else {
        const errorData = await response.json();
        console.error('Failed to generate project:', errorData);
        alert(`Error from server: ${errorData.detail || 'Unknown error'}`);
      }
    } catch (error) {
      console.error('Error submitting configuration:', error);
      alert('An error occurred while contacting the server. Is it running?');
    }
  };

  return (
    <div className='text-center p-4'>
      <h2 className='text-3xl font-bold mb-2 text-gray-800 dark:text-white'>
        Review Your Configuration
      </h2>
      <p className='text-lg text-gray-600 dark:text-gray-300 mb-6'>
        One last look before we generate your project!
      </p>      <div className='text-left bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg p-6 mt-6'>
        <div className='mb-6'>
          <h4 className='text-xl font-bold border-b-2 border-blue-500 pb-2 mb-4 text-gray-800 dark:text-white'>
            Project
          </h4>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Name:</strong> {config.projectName}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Description:</strong> {config.backend.projectDescription}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Version:</strong> {config.backend.projectVersion}
          </p>
        </div>

        <div className='mb-6'>
          <h4 className='text-xl font-bold border-b-2 border-blue-500 pb-2 mb-4 text-gray-800 dark:text-white'>
            Backend
          </h4>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Framework:</strong> {config.backend.framework}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Database:</strong> {config.backend.database}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Database Name:</strong> {config.backend.dbName}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Database User:</strong> {config.backend.dbUser}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Debug Mode:</strong> {config.backend.debug ? 'Enabled' : 'Disabled'}
          </p>
        </div>

        <div className='mb-6'>
          <h4 className='text-xl font-bold border-b-2 border-blue-500 pb-2 mb-4 text-gray-800 dark:text-white'>
            Frontend
          </h4>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Framework:</strong> {config.frontend.framework}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>UI Library:</strong> {config.frontend.uiLibrary}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Example Pages:</strong> {config.frontend.includeExamplePages ? 'Included' : 'Not included'}
          </p>
          <p className='text-gray-700 dark:text-gray-300'>
            <strong>Husky (Git Hooks):</strong> {config.frontend.includeHusky ? 'Included' : 'Not included'}
          </p>
        </div>

        <div>
          <h4 className='text-xl font-bold border-b-2 border-blue-500 pb-2 mb-4 text-gray-800 dark:text-white'>
            Modules
          </h4>
          {Object.entries(config.modules).some(([, value]) => value) ? (
            <ul className='list-disc list-inside text-gray-700 dark:text-gray-300'>
              {Object.entries(config.modules).map(([key, value]) =>
                value ? <li key={key}>{key.charAt(0).toUpperCase() + key.slice(1)}</li> : null,
              )}
            </ul>
          ) : (
            <p className='text-gray-700 dark:text-gray-300 italic'>No additional modules selected</p>
          )}
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
          onClick={submit}
          className='bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-6 rounded-lg transition-transform transform hover:scale-105'
        >
          Generate Project
        </button>
      </div>
    </div>
  );
};

ReviewStep.propTypes = {
  prevStep: PropTypes.func.isRequired,
  nextStep: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
};

export default ReviewStep;
