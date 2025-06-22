import React from 'react';
import Wizard from './components/wizard/Wizard';
import './App.css';

/**
 * The main application component.
 * It serves as the root of the React application and renders the main Wizard interface.
 * @returns {JSX.Element} The rendered App component.
 */
function App() {
  return (
    <div className='App w-full max-w-full overflow-x-hidden'>
      <Wizard />
    </div>
  );
}

export default App;
