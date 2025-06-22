import React from 'react';
import { motion } from 'framer-motion';

const Mascot = () => {
  const bodyVariants = {
    breathing: {
      scale: [1, 1.05, 1],
      transition: {
        duration: 2,
        repeat: Infinity,
        ease: 'easeInOut',
      },
    },
  };

  return (
    <div className='relative w-24 h-24 mx-auto my-4'>
      <motion.div
        className='w-24 h-20 bg-blue-500 rounded-t-full rounded-b-lg relative overflow-hidden'
        variants={bodyVariants}
        animate='breathing'
      >
        <div className='absolute w-4 h-4 bg-white rounded-full top-7 left-6'></div>
        <div className='absolute w-4 h-4 bg-white rounded-full top-7 right-6'></div>
      </motion.div>
      <div className='absolute w-10 h-5 border-4 border-white border-t-0 rounded-b-2xl bottom-2 left-1/2 transform -translate-x-1/2'></div>
    </div>
  );
};

export default Mascot;
