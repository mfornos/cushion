define 'template/helpers/users', ['handlebars'], (Handlebars) -> 
	
  users = (context, options)->
    ret = ''
    all = []
    all.push context.user

    if context.assignee and context.assignee.id != context.user.id
      all.push context.assignee

    for user in all
      do (user)->
        ret += options.fn user

    return ret

 	Handlebars.registerHelper('users', users)
