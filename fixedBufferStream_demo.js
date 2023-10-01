const dogs = [
  { name: "Rex", age: 5 },
  { name: "Fido", age: 3 },
];

const buffer = dogs.map((dog) => dog.name).join(" ");
console.log(buffer);
