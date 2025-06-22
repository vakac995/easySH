// Sound effects system with proper AudioContext management
let audioContext = null;
let audioEnabled = false;
let userInteracted = false;

// Initialize audio context after user interaction
const initializeAudio = async () => {
  if (typeof window === 'undefined' || !window.AudioContext) {
    return false;
  }

  try {
    if (!audioContext) {
      audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }

    // Resume the audio context if it's suspended
    if (audioContext.state === 'suspended') {
      await audioContext.resume();
    }

    audioEnabled = audioContext.state === 'running';
    return audioEnabled;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.log('Audio initialization failed:', error.message);
    }
    return false;
  }
};

// Enable audio on first user interaction
const enableAudioOnInteraction = () => {
  if (userInteracted) return;
  
  userInteracted = true;
  initializeAudio().then((enabled) => {
    if (enabled && process.env.NODE_ENV === 'development') {
      console.log('Audio enabled after user interaction');
    }
  });
};

// Set up event listeners for user interaction (only once)
if (typeof window !== 'undefined' && !userInteracted) {
  const events = ['click', 'touchstart', 'keydown'];
  const handleInteraction = () => {
    events.forEach(event => {
      document.removeEventListener(event, handleInteraction, { passive: true });
    });
    enableAudioOnInteraction();
  };
  
  events.forEach(event => {
    document.addEventListener(event, handleInteraction, { passive: true });
  });
}

// Check if audio is available and ready
const isAudioReady = async () => {
  if (!userInteracted) {
    return false;
  }

  if (!audioEnabled) {
    audioEnabled = await initializeAudio();
  }

  return audioEnabled && audioContext && audioContext.state === 'running';
};

export const playAchievementSound = async () => {
  if (!(await isAudioReady())) return;

  try {
    // Create a simple achievement sound (ascending notes)
    const frequencies = [523.25, 659.25, 783.99]; // C5, E5, G5
    let startTime = audioContext.currentTime;

    frequencies.forEach((freq, index) => {
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.setValueAtTime(freq, startTime + index * 0.1);
      oscillator.type = 'sine';

      gainNode.gain.setValueAtTime(0, startTime + index * 0.1);
      gainNode.gain.linearRampToValueAtTime(0.3, startTime + index * 0.1 + 0.05);
      gainNode.gain.exponentialRampToValueAtTime(0.01, startTime + index * 0.1 + 0.3);

      oscillator.start(startTime + index * 0.1);
      oscillator.stop(startTime + index * 0.1 + 0.3);
    });
  } catch (error) {
    // Silently fail - this is expected behavior when audio is restricted
    if (process.env.NODE_ENV === 'development') {
      console.log('Achievement sound failed to play:', error.message);
    }
  }
};

export const playPowerUpSound = async () => {
  if (!(await isAudioReady())) return;

  try {
    // Create a power-up sound (rising frequency)
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);

    const startTime = audioContext.currentTime;
    oscillator.frequency.setValueAtTime(220, startTime);
    oscillator.frequency.exponentialRampToValueAtTime(880, startTime + 0.5);
    oscillator.type = 'sawtooth';

    gainNode.gain.setValueAtTime(0, startTime);
    gainNode.gain.linearRampToValueAtTime(0.2, startTime + 0.1);
    gainNode.gain.exponentialRampToValueAtTime(0.01, startTime + 0.5);
    
    oscillator.start(startTime);
    oscillator.stop(startTime + 0.5);
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.log('Power-up sound failed to play:', error.message);
    }
  }
};

export const playCelebrationSound = async () => {
  if (!(await isAudioReady())) return;

  try {
    // Create a celebration fanfare
    const melody = [
      { freq: 659.25, duration: 0.2 }, // E5
      { freq: 659.25, duration: 0.2 }, // E5
      { freq: 659.25, duration: 0.4 }, // E5
      { freq: 659.25, duration: 0.2 }, // E5
      { freq: 659.25, duration: 0.2 }, // E5
      { freq: 659.25, duration: 0.4 }, // E5
      { freq: 659.25, duration: 0.2 }, // E5
      { freq: 783.99, duration: 0.2 }, // G5
      { freq: 523.25, duration: 0.2 }, // C5
      { freq: 587.33, duration: 0.2 }, // D5
      { freq: 659.25, duration: 0.6 }, // E5
    ];

    let currentTime = audioContext.currentTime;

    melody.forEach((note) => {
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.setValueAtTime(note.freq, currentTime);
      oscillator.type = 'square';

      gainNode.gain.setValueAtTime(0, currentTime);
      gainNode.gain.linearRampToValueAtTime(0.1, currentTime + 0.01);
      gainNode.gain.exponentialRampToValueAtTime(0.01, currentTime + note.duration);

      oscillator.start(currentTime);
      oscillator.stop(currentTime + note.duration);
      currentTime += note.duration;
    });
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.log('Celebration sound failed to play:', error.message);
    }
  }
};

// Utility function to check if sound is enabled
export const isSoundEnabled = () => {
  return userInteracted && audioEnabled;
};

// Utility function to manually enable sound (for settings toggle)
export const enableSound = async () => {
  userInteracted = true;
  return await initializeAudio();
};
