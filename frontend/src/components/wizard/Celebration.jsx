import React from 'react';
import { motion } from 'framer-motion';
import PropTypes from 'prop-types';

const ConfettiPiece = ({ delay, color, shape }) => (
  <motion.div
    className={`absolute ${shape === 'star' ? 'w-4 h-4' : 'w-3 h-3'} ${color} ${shape === 'star' ? '' : 'rounded-full'}`}
    style={
      shape === 'star'
        ? {
            clipPath:
              'polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%)',
          }
        : {}
    }
    initial={{ y: -100, x: 0, rotate: 0, opacity: 1, scale: 0 }}
    animate={{
      y: typeof window !== 'undefined' ? window.innerHeight + 100 : 800,
      x: Math.random() * 400 - 200,
      rotate: 720 + Math.random() * 360,
      opacity: 0,
      scale: [0, 1, 0.8, 0],
    }}
    transition={{
      duration: 4 + Math.random() * 2,
      delay: delay,
      ease: 'easeOut',
    }}
  />
);

ConfettiPiece.propTypes = {
  delay: PropTypes.number.isRequired,
  color: PropTypes.string.isRequired,
  shape: PropTypes.string,
};

const Firework = ({ delay }) => (
  <motion.div
    className='absolute'
    style={{
      left: `${20 + Math.random() * 60}%`,
      top: `${20 + Math.random() * 60}%`,
    }}
    initial={{ scale: 0, opacity: 0 }}
    animate={{
      scale: [0, 1, 0],
      opacity: [0, 1, 0],
    }}
    transition={{
      duration: 1.5,
      delay: delay,
      ease: 'easeOut',
    }}
  >
    {Array.from({ length: 8 }, (_, i) => (
      <motion.div
        key={i}
        className='absolute w-1 h-8 bg-gradient-to-t from-yellow-400 to-transparent'
        style={{
          transformOrigin: 'bottom center',
          rotate: `${i * 45}deg`,
        }}
        animate={{
          scaleY: [0, 1, 0],
          opacity: [1, 0.5, 0],
        }}
        transition={{
          duration: 1,
          delay: delay,
        }}
      />
    ))}
  </motion.div>
);

Firework.propTypes = {
  delay: PropTypes.number.isRequired,
};

const Celebration = () => {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.3,
        delayChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 80, opacity: 0, scale: 0.3 },
    visible: {
      y: 0,
      opacity: 1,
      scale: 1,
      transition: {
        type: 'spring',
        stiffness: 200,
        damping: 15,
      },
    },
  };

  const confettiColors = [
    'bg-gradient-to-br from-yellow-400 to-orange-500',
    'bg-gradient-to-br from-blue-400 to-indigo-500',
    'bg-gradient-to-br from-green-400 to-emerald-500',
    'bg-gradient-to-br from-red-400 to-pink-500',
    'bg-gradient-to-br from-purple-400 to-violet-500',
    'bg-gradient-to-br from-cyan-400 to-blue-500',
    'bg-gradient-to-br from-pink-400 to-rose-500',
  ];

  const confettiItems = Array.from({ length: 50 }, (_, i) => ({
    id: `confetti-piece-${i}`,
    delay: i * 0.05 + Math.random() * 0.5,
    color: confettiColors[i % confettiColors.length],
    shape: i % 4 === 0 ? 'star' : 'circle',
  }));

  const fireworkItems = Array.from({ length: 6 }, (_, i) => ({
    id: `firework-${i}`,
    delay: i * 0.3 + 0.5,
  }));

  return (
    <motion.div
      className='fixed top-0 left-0 w-full h-full bg-gradient-to-br from-purple-900/95 via-blue-900/95 to-indigo-900/95 backdrop-blur-sm flex flex-col justify-center items-center z-50 text-white overflow-hidden'
      initial='hidden'
      animate='visible'
      variants={containerVariants}
    >
      {/* Animated Background */}
      <motion.div
        className='absolute inset-0 bg-gradient-radial from-purple-500/30 via-blue-500/20 to-transparent'
        animate={{
          scale: [1, 1.3, 1],
          opacity: [0.3, 0.7, 0.3],
          rotate: [0, 180, 360],
        }}
        transition={{
          repeat: Infinity,
          duration: 8,
          ease: 'easeInOut',
        }}
      />

      {/* Confetti Animation */}
      {confettiItems.map((item) => (
        <ConfettiPiece key={item.id} delay={item.delay} color={item.color} shape={item.shape} />
      ))}

      {/* Fireworks */}
      {fireworkItems.map((item) => (
        <Firework key={item.id} delay={item.delay} />
      ))}

      {/* Main Content */}
      <motion.div className='text-center z-10 px-8' variants={containerVariants}>
        <motion.h1
          variants={itemVariants}
          className='text-7xl font-bold mb-6 bg-gradient-to-r from-yellow-300 via-pink-400 to-purple-500 bg-clip-text text-transparent drop-shadow-2xl'
          animate={{
            textShadow: [
              '0 0 20px rgba(255,255,255,0.5)',
              '0 0 40px rgba(255,255,255,0.8)',
              '0 0 20px rgba(255,255,255,0.5)',
            ],
          }}
          transition={{ repeat: Infinity, duration: 2 }}
        >
          🎉 CONGRATULATIONS! 🎉
        </motion.h1>

        <motion.p
          variants={itemVariants}
          className='text-3xl mb-6 font-semibold text-white drop-shadow-lg'
        >
          You've completed your project configuration!
        </motion.p>

        <motion.div variants={itemVariants} className='flex justify-center space-x-8 text-6xl mb-8'>
          <motion.span
            animate={{
              rotate: [0, 15, -15, 0],
              scale: [1, 1.2, 1],
            }}
            transition={{ repeat: Infinity, duration: 2, ease: 'easeInOut' }}
            className='drop-shadow-2xl'
          >
            🏆
          </motion.span>
          <motion.span
            animate={{
              scale: [1, 1.3, 1],
              y: [0, -10, 0],
            }}
            transition={{ repeat: Infinity, duration: 1.8, ease: 'easeInOut' }}
            className='drop-shadow-2xl'
          >
            ⚡
          </motion.span>
          <motion.span
            animate={{
              rotate: [0, -15, 15, 0],
              scale: [1, 1.1, 1],
            }}
            transition={{ repeat: Infinity, duration: 2.2, ease: 'easeInOut' }}
            className='drop-shadow-2xl'
          >
            🚀
          </motion.span>
        </motion.div>

        <motion.div
          variants={itemVariants}
          className='bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 shadow-2xl'
        >
          <p className='text-xl text-white/90 font-medium leading-relaxed'>
            Your project is ready to be generated with all your chosen configurations!
          </p>
          <motion.div
            className='mt-4 flex justify-center'
            animate={{ scale: [1, 1.05, 1] }}
            transition={{ repeat: Infinity, duration: 3 }}
          >
            <span className='text-2xl'>✨ Ready to Build! ✨</span>
          </motion.div>
        </motion.div>
      </motion.div>

      {/* Enhanced Pulse Effects */}
      <motion.div
        className='absolute inset-0 bg-gradient-conic from-yellow-400/20 via-purple-500/20 to-blue-500/20'
        animate={{
          rotate: [0, 360],
          scale: [0.8, 1.2, 0.8],
          opacity: [0.1, 0.3, 0.1],
        }}
        transition={{
          repeat: Infinity,
          duration: 6,
          ease: 'linear',
        }}
      />
    </motion.div>
  );
};

export default Celebration;
