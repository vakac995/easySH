import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { motion } from 'framer-motion';

const achievementVariants = {
  hidden: { opacity: 0, y: 60, scale: 0.7, x: 120, rotate: 5 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    x: 0,
    rotate: 0,
    transition: {
      type: 'spring',
      stiffness: 400,
      damping: 20,
      duration: 0.8,
      ease: 'easeOut',
    },
  },
  exit: {
    opacity: 0,
    x: 120,
    scale: 0.7,
    rotate: -5,
    transition: { duration: 0.4, ease: 'easeIn' },
  },
};

const Achievement = ({ title, icon, description = '', isNew = false }) => {
  const [isVisible, setIsVisible] = useState(true);

  useEffect(() => {
    if (isNew) {
      // Auto-hide achievement after 6 seconds
      const timer = setTimeout(() => {
        setIsVisible(false);
      }, 6000);

      return () => clearTimeout(timer);
    }
  }, [isNew]);

  if (!isVisible) return null;

  return (
    <motion.div
      className='relative flex items-start bg-gradient-to-br from-green-500 via-emerald-500 to-teal-500 text-white rounded-2xl shadow-2xl mb-3 w-80 cursor-pointer hover:from-green-600 hover:via-emerald-600 hover:to-teal-600 transition-all duration-300 border-2 border-white/30 backdrop-blur-sm'
      variants={achievementVariants}
      initial='hidden'
      animate='visible'
      exit='exit'
      onClick={() => setIsVisible(false)}
      whileHover={{ scale: 1.03, x: -8, rotate: 1 }}
      whileTap={{ scale: 0.97 }}
    >
      {' '}
      {/* Shine effect */}
      <motion.div
        className='absolute top-0 left-0 right-0 bottom-0 bg-gradient-to-r from-transparent via-white/30 to-transparent rounded-2xl'
        initial={{ x: '-120%' }}
        animate={{ x: '120%' }}
        transition={{ duration: 2, delay: 0.3, ease: 'easeInOut' }}
      />
      {/* Floating particles effect */}
      <div className='absolute inset-0 overflow-hidden rounded-2xl'>
        <motion.div
          className='absolute w-2 h-2 bg-white/40 rounded-full'
          animate={{
            x: [0, 20, 0],
            y: [0, -15, 0],
            opacity: [0, 1, 0],
          }}
          transition={{ duration: 3, repeat: Infinity, delay: 0.5 }}
          style={{ left: '20%', top: '30%' }}
        />
        <motion.div
          className='absolute w-1 h-1 bg-white/50 rounded-full'
          animate={{
            x: [0, -15, 0],
            y: [0, -10, 0],
            opacity: [0, 1, 0],
          }}
          transition={{ duration: 2.5, repeat: Infinity, delay: 1 }}
          style={{ right: '25%', top: '60%' }}
        />
      </div>
      {/* Achievement badge */}
      <motion.div
        className='absolute -top-3 -right-3 bg-gradient-to-br from-yellow-400 to-orange-500 text-white text-sm font-bold px-3 py-1 rounded-full shadow-xl border-2 border-white z-20'
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        transition={{ delay: 0.5, type: 'spring', stiffness: 500 }}
      >
        🏆
      </motion.div>{' '}
      {/* Content */}
      <div className='flex items-start space-x-4 p-5 relative z-10 w-full'>
        <div className='flex-shrink-0 mt-1'>
          <motion.div
            className='w-12 h-12 bg-white/25 backdrop-blur-sm rounded-2xl flex items-center justify-center text-2xl border border-white/30 shadow-lg'
            initial={{ rotate: -45, scale: 0.5 }}
            animate={{ rotate: 0, scale: 1 }}
            transition={{ delay: 0.2, type: 'spring', stiffness: 300 }}
          >
            {icon}
          </motion.div>
        </div>
        <div className='flex-1 min-w-0 pr-8'>
          <motion.h4
            className='font-bold text-base leading-tight mb-2 text-white drop-shadow-sm'
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
          >
            {title}
          </motion.h4>
          {description && (
            <motion.p
              className='text-sm text-white/90 leading-relaxed line-clamp-2 drop-shadow-sm'
              initial={{ x: -20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.4 }}
            >
              {description}
            </motion.p>
          )}
        </div>
      </div>
      {/* Close button */}
      <motion.button
        onClick={(e) => {
          e.stopPropagation();
          setIsVisible(false);
        }}
        className='absolute top-3 right-3 text-white/60 hover:text-white text-lg font-bold w-6 h-6 flex items-center justify-center rounded-full hover:bg-white/20 transition-all duration-200 backdrop-blur-sm'
        whileHover={{ scale: 1.2, rotate: 90 }}
        whileTap={{ scale: 0.8 }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6 }}
      >
        ✕
      </motion.button>
    </motion.div>
  );
};

Achievement.propTypes = {
  title: PropTypes.string.isRequired,
  icon: PropTypes.string.isRequired,
  description: PropTypes.string,
  isNew: PropTypes.bool,
};

export default Achievement;
