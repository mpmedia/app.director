<?php
class TasksAppController extends AppController {

	var $name = 'TasksApp';
    var $uses = array();
    
    function beforeFilter() {
        $this->autoRender = true;
        $this->layout = 'tasks_layout';
    }
    
    function index() {}

}
?>