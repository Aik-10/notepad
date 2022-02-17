function limitLines(obj, limit) {
    let values = obj.value.replace(/\r\n/g,"\n").split("\n")
    if (values.length > limit) {
      obj.value = values.slice(0, limit).join("\n")
    }
}