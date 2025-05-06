export function formatDate(date: Date) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  const suffixes = ["st", "nd", "rd", "th"];
  const month = months[date.getMonth()];
  const day = date.getDate();
  const year = date.getFullYear();
  const hours = date.getHours();
  const minutes = date.getMinutes();
  const period = hours >= 12 ? "pm" : "am";
  const formattedHours = hours % 12 === 0 ? 12 : hours % 12;
  const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
  const suffix = day >= 1 && day <= 3 ? suffixes[day - 1] : suffixes[3];

  return `${month} ${day}${suffix}, ${year} at ${formattedHours}:${formattedMinutes}${period}`;
}
