package model;

/**
 *
 * @author Trung Hieu
 */
public class Role {

    private int roleID;
    private String roleName;
    private String description;
    private boolean status;

    public Role() {
    }

    public Role(int roleID, String roleName, String description, boolean status) {
        this.roleID = roleID;
        this.roleName = roleName;
        this.description = description;
        this.status = status;
    }

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
}