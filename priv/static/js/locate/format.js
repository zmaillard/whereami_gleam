export function lengthOfDay({ sunrise, sunset }) {
  const milliseconds = Math.abs(sunset - sunrise);
  const secs = Math.floor(Math.abs(milliseconds) / 1000);
  const mins = Math.floor(secs / 60);
  const hours = Math.floor(mins / 60);

  return `${hours % 24} hours and ${mins % 60} minutes`
}

export function formatTime(ms, timeZone) {

  return new Date(ms).toLocaleTimeString("en-US", {
    timeZone
  });
}

export function timeDetails(snow, place) {
  return `It is ${snow.format('time')} in ${place}.`
}

/*
import spacetime from 'spacetime'

// Start with a date in Toronto.
const toronto = spacetime('2026-10-09', 'America/Toronto').time('9:30am')

// View the same moment in another timezone.
const london = toronto.goto('Europe/London')

// format it, any way:
const str = london.format('{day-short}, {time}')
// 'Fri, 2:30pm'*/
