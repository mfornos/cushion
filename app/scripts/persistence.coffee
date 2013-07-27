###
  
  Naive cookie based storage for demonstration

###
define ['jquery'], ($)->

  Cookies = class Cookies

    @dayMillis: 24*60*60*1000

    @read: (name)->
      ca = document.cookie.split('; ')
      for p in ca
        kv = p.split('=')
        return unescape kv[1] if kv[0] is name
       
    @write: (name, value, days = 15)->
      expires = new Date()
      expires.setTime(expires.getTime() + (days * Cookies.dayMillis))
      document.cookie = "#{name}=#{escape(value)};expires=#{expires.toGMTString()}"

    @erase: (name)->
      Cookies.write(name, '', '1970-01-01 12:00:00')

  Store = class CookieStore

    remove: (k)-> Cookies.erase(k)
    save: (k, v)-> Cookies.write(k, v)
    read: (k)-> Cookies.read(k)

    onReorder: (el)->
      oc = Cookies.read("order-#{el.attr('id')}")
      $.each(JSON.parse(oc), (k, v)-> el.append $("##{v}")) if oc

    onUpdate: (el)->
      Cookies.write("order-#{el.attr('id')}", JSON.stringify(el.sortable('toArray')), 365)

  Store
    

