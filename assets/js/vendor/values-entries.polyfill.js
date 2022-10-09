// object-values | MIT | github.com/tc39/proposal-object-values-entries

const reduce = Function.bind.call(Function.call, Array.prototype.reduce);
const isEnumerable = Function.bind.call(Function.call, Object.prototype.propertyIsEnumerable);
const concat = Function.bind.call(Function.call, Array.prototype.concat);

if (!Object.values) {
  Object.values = function values(O) {
    return reduce(Object.keys(O), (v, k) => concat(v, typeof k === 'string' && isEnumerable(O, k) ? [O[k]] : []), []);
  };
}

if (!Object.entries) {
  Object.entries = function entries(O) {
    return reduce(Object.keys(O), (e, k) => concat(e, typeof k === 'string' && isEnumerable(O, k) ? [[k, O[k]]] : []), []);
  };
}
