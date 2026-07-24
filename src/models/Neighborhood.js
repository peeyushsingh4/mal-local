export class Neighborhood {
  constructor({ id, name, city, area }) {
    this.id = id;
    this.name = name;
    this.city = city;
    this.area = area;
  }
}

export const BANDRA_WEST = new Neighborhood({
  id: 'bandra-west',
  name: 'Bandra West',
  city: 'Mumbai',
  area: 'Bandra (W)'
});
