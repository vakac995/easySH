/**
 * @file AnimatedStep.jsx
 * @description This component provides a consistent animation for each step in the wizard.
 * It uses framer-motion to animate the entry and exit of each step.
 * @requires react
 * @requires framer-motion
 * @requires prop-types
 */

import React from 'react';
import { motion } from 'framer-motion';
import PropTypes from 'prop-types';

const stepVariants = {
  hidden: {
    opacity: 0,
    scale: 0.98,
  },
  visible: {
    opacity: 1,
    scale: 1,
    transition: { duration: 0.4, ease: 'easeInOut' },
  },
  exit: {
    opacity: 0,
    scale: 0.98,
    transition: { duration: 0.2, ease: 'easeInOut' },
  },
};

/**
 * A component that provides a consistent animation for each step in the wizard.
 * @param {object} props - The component's props.
 * @param {React.ReactNode} props.children - The content of the step.
 * @returns {JSX.Element} The animated step component.
 */
const AnimatedStep = ({ children }) => {
  return (
    <motion.div variants={stepVariants} initial='hidden' animate='visible' exit='exit'>
      {children}
    </motion.div>
  );
};

AnimatedStep.propTypes = {
  children: PropTypes.node.isRequired,
};

export default AnimatedStep;
