# What does the task library needs ?
#  - it needs to be able to include the <toolkit_name>ToolkitTypes.hpp files for
#    each used toolkit. It does not need to link the library, though, because the
#    toolkit itself is hidden from the actual task contexts.
#  - it needs to have access to the dependent task libraries and libraries. This
#    is true for both the headers and the link interface itself.
#
# What this file does is set up the following variables:
#  component_TASKLIB_NAME
#     the name of the library (test-tasks-gnulinux for instance)
#
#  <PROJECT>_TASKLIB_SOURCES
#     the .cpp files that define the task context classes, including the
#     autogenerated parts.
#
#  <PROJECT>_TASKLIB_SOURCES
#     the .hpp files that declare the task context classes, including the
#     autogenerated parts.
#
#  <PROJECT>_TASKLIB_DEPENDENT_LIBRARIES
#     the list of libraries to which the task library should be linked.
#
# These variables are used in tasks/CMakeLists.txt to actually build the shared
# object.

<% if component.toolkit %>
include_directories(${PROJECT_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>/toolkit)
<% end %>
<% related_toolkits = component.tasks.inject(ValueSet.new) { |set, task| set | task.used_toolkits }
 related_toolkits.each do |tk| %>
pkg_check_modules(<%= tk.name %>_TOOLKIT REQUIRED <%= tk.name %>-toolkit-${OROCOS_TARGET})
include_directories(${<%= tk.name %>_TOOLKIT_INCLUDE_DIRS})
<% end %>

<% component.used_libraries.each do |pkg|
name = pkg.name %>
pkg_check_modules(<%= name %> REQUIRED <%= name %>)
INCLUDE_DIRECTORIES(${<%= name %>_INCLUDE_DIRS})
LINK_DIRECTORIES(${<%= name %>_LIBRARY_DIRS})
list(APPEND <%= component.name.upcase %>_TASKLIB_DEPENDENT_LIBRARIES ${<%= name %>_LIBRARIES})
<% end %>

<% component.used_task_libraries.each do |pkg|
    name = pkg.name %>
pkg_check_modules(<%= name %>_TASKLIB REQUIRED <%= name %>-tasks-${OROCOS_TARGET})
INCLUDE_DIRECTORIES(${<%= name %>_TASKLIB_INCLUDE_DIRS})
LINK_DIRECTORIES(${<%= name %>_TASKLIB_LIBRARY_DIRS})
list(APPEND <%= component.name.upcase %>_TASKLIB_DEPENDENT_LIBRARIES ${<%= name %>_TASKLIB_LIBRARIES})
list(APPEND <%= component.name.upcase %>_TASKLIB_INTERFACE_LIBRARIES ${<%= name %>_TASKLIB_LIBRARIES})
<% end %>

CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>/tasks/<%= component.name %>-tasks.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/<%= component.name %>-tasks-${OROCOS_TARGET}.pc @ONLY)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/<%= component.name %>-tasks-${OROCOS_TARGET}.pc
    DESTINATION lib/pkgconfig)

INSTALL(FILES <%= component.deffile %>
    DESTINATION share/orogen)

<% 
   include_files = []
   task_files = []
   component.self_tasks.each do |task| 
     if !task_files.empty?
	 task_files << "\n    "
     end
     task_files << "${CMAKE_SOURCE_DIR}/#{Generation::AUTOMATIC_AREA_NAME}/tasks/#{task.basename}Base.cpp"
     task_files << "#{task.basename}.cpp"
     include_files << "${CMAKE_SOURCE_DIR}/#{Generation::AUTOMATIC_AREA_NAME}/tasks/#{task.basename}Base.hpp"
     include_files << "#{task.basename}.hpp"
   end
%>

set(<%= component.name.upcase %>_TASKLIB_NAME <%= component.name %>-tasks-${OROCOS_TARGET})
set(<%= component.name.upcase %>_TASKLIB_SOURCES <%= task_files.join(" ") %>)
set(<%= component.name.upcase %>_TASKLIB_HEADERS <%= include_files.join(" ") %>)
include_directories(${OrocosRTT_INCLUDE_DIRS})
link_directories(${OrocosRTT_LIBRARY_DIRS})
add_definitions(${OrocosRTT_CFLAGS_OTHER})

