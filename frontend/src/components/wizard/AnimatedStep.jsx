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
