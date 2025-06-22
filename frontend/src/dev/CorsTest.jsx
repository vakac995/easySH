import React, { useState } from 'react';
import { runAllCORSTests } from '../utils/corsTest';

const CorsTest = () => {
  const [corsTestResults, setCorsTestResults] = useState(null);
  const [corsTestLoading, setCorsTestLoading] = useState(false);

  const handleCORSTest = async () => {
    setCorsTestLoading(true);
    try {
      const results = await runAllCORSTests();
      setCorsTestResults(results);
    } catch (error) {
      setCorsTestResults({ error: error.message });
    } finally {
      setCorsTestLoading(false);
    }
  };

  return (
    <div className='fixed top-4 right-4 z-50 bg-gray-800 text-white p-3 rounded-lg shadow-lg max-w-sm'>
      <div className='text-sm font-bold mb-2'>🔧 Dev Tools</div>
      <button
        onClick={handleCORSTest}
        disabled={corsTestLoading}
        className='bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-3 py-1 rounded text-sm mb-2 w-full'
      >
        {corsTestLoading ? 'Testing CORS...' : 'Test CORS Connection'}
      </button>
      {corsTestResults && (
        <div className='text-xs'>
          <div
            className={`font-bold ${corsTestResults.overallSuccess ? 'text-green-400' : 'text-red-400'}`}
          >
            {corsTestResults.overallSuccess ? '✅ CORS OK' : '❌ CORS Issues'}
          </div>
          <div className='text-gray-300 mt-1'>API: {corsTestResults.apiBaseUrl}</div>
          {corsTestResults.corsTests?.errors?.length > 0 && (
            <div className='text-red-300 text-xs mt-1'>
              Errors: {corsTestResults.corsTests.errors.join(', ')}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default CorsTest;
